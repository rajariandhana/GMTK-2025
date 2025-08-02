extends Control

@onready var deck := $Deck
@onready var trash := $Trash
@onready var board := $Board
@onready var hand := $Hand
@onready var combo: Node = $Combo
@onready var card_path := preload("res://card.tscn")

@onready var board_pos: Node2D = $BoardPositions
@onready var hand_pos: Node2D = $HandPositions
@onready var state_label: Label = $StatusLabel
@onready var sfx_discard: AudioStreamPlayer = $Discarded

var selected_card : Card
var state: int = State.IDLE:
	set(value):
		state_machine(value)



var suits = ["", "♠️", "♥️", "♣️", "♦️"]
var current_loop = 0

var card_vector2 = Vector2(-50, -75)

var hand_limit : int = 4

var board_positions := []
var hand_positions := []
var trash_position := Vector2(982, 428)
var deck_positions := Vector2(70, 70)


func _ready() -> void:
	await generate_cards()
	state = State.LOOP_ENDED
		
	board_positions=[]
	for pos in board_pos.get_children():
		board_positions.append(pos.global_position + card_vector2)
	
	hand_positions=[]
	for pos in hand_pos.get_children():
		hand_positions.append(pos.global_position + card_vector2)


func generate_cards():
	var tweens_to_check = []
	match current_loop:
		0:
			for suit in range(2):
				for value in range(1, 10):
					tweens_to_check.append(await add_card(suit, value))
		1:
			for value in range(1, 10):
					tweens_to_check.append(await add_card(2, value))
		2:
			for suit in range(3):
				for value in range(10, 14):
					tweens_to_check.append(await add_card(suit, value))
		3:
			for value in range(1, 14):
					tweens_to_check.append(await add_card(3, value))
	for t : Tween in tweens_to_check:
		if t.is_running():
			await t.finished


func add_card(suit, value):
	var card_instance : Card = card_path.instantiate()
	trash.add_child(card_instance)
	card_instance.set_info(suit, value)
	card_instance.connect("selected", card_selected)
	card_instance.position = $"Deck-2".position
	var t : Tween = create_tween()
	t.tween_property(card_instance, "position", trash_position + Vector2(0, -trash.get_child_count() - 1), 0.8)
	await get_tree().create_timer(0.03).timeout
	return t


func shuffle_cards():
	var children = deck.get_children()
	children.shuffle()
	for child in children:
		deck.remove_child(child)
	for child in children:
		deck.add_child(child)
	if is_dead_end(children.slice(len(children) - 7, len(children))):
		shuffle_cards()
		


func state_machine(state):
	if state == State.LOOP_ENDED:
		state_label.text = ""
		state = State.SHUFFLING
		await loop_deck()
		current_loop += 1
	if state == State.SHUFFLE_FINISHED:
		await updraw()
	if state == State.DEAD_END:
		$DeadEndLabel.visible = true
		return
	if state != State.IDLE:
		return
		
	state_label.text = "LOOP " + str(current_loop)
	if board.get_child_count() < 3 and deck.get_child_count() == 0:
		discard_many(hand.get_children())
		discard_many(board.get_children())
		
		await get_tree().create_timer(1).timeout
		await generate_cards()
		await get_tree().create_timer(0.5).timeout
		state = State.LOOP_ENDED
		state_machine(state)
		return
		
	if board.get_child(0).value == board.get_child(1).value and board.get_child(0).value == board.get_child(2).value:
		state = State.TWEENING
		var card_from_deck : Card = null
		for c in deck.get_children():
			if c.value == board.get_child(0).value:
				card_from_deck = c
				deck.remove_child(card_from_deck)
				board.add_child(card_from_deck)
				var t : Tween = create_tween()
				card_from_deck.flip()
				t.tween_property(card_from_deck, "position", get_viewport_rect().size / 2 + Vector2(-370, -100), 0.8)
				await t.finished
				break
		await discard_many(board.get_children())
		await updraw()
		return
		
	var board_cards = board.get_children()
	var cleans = combo.clean(board_cards)
	if combo.same_suit(cleans):
		combo.combo_detector(cleans)
		await discard_many(board_cards)
		await updraw()


func discard_many(cards: Array):
	var sorted = []
	var tweens_to_check = []
	for card in cards:
		var dist = card.position.distance_to(trash_position)
		sorted.append([dist, card])
	sorted.sort()

	for c in sorted:
		var card = c[1]
		tweens_to_check.append(discard_one(card)) 
	for t : Tween in tweens_to_check:
		await t.finished


func discard_one(card: Card) -> Tween:
	if selected_card == card:
		selected_card = null
	var t : Tween = card.create_tween()
	card.get_parent().remove_child(card)
	trash.add_child(card)
	var target_position := Vector2(trash_position.x, trash_position.y - trash.get_child_count())
	t.tween_property(card, "position", target_position, card.position.distance_to(target_position) * 0.001)
	sfx_discard.play()
	return t


func updraw():
	$DeckLooped.stop()
	$DeckLooped.play()
	state = State.TWEENING
	var hand_len := hand.get_child_count()
	var board_len := board.get_child_count()
	
	var tweens_to_check = []
	
	for i in 3 - board_len:
		if deck.get_child_count() == 0:
			break
		var t : Tween = create_tween()
		t.set_ease(Tween.EASE_IN_OUT)
		tweens_to_check.append(t)
		var card = deck.get_child(-1)
		card.flip()
		card.text = suits[card.suit]
		deck.remove_child(card)
		board.add_child(card)
		t.tween_property(card, "position", board_positions[i], 0.4)
		await get_tree().create_timer(0.03).timeout
		
	for i in hand_limit - hand_len:
		if deck.get_child_count() == 0:
			break
		var t : Tween = create_tween()
		t.set_ease(Tween.EASE_IN_OUT)
		tweens_to_check.append(t)
		var card = deck.get_child(-1)
		card.flip()
		card.text = suits[card.suit]
		deck.remove_child(card)
		hand.add_child(card)
		t.tween_property(card, "position", hand_positions[i], 0.4)
		await get_tree().create_timer(0.03).timeout
	
	for t : Tween in tweens_to_check:
		await t.finished
	$DeckLooped.stop()
	if is_dead_end():
		state = State.DEAD_END
		return
	state = State.IDLE


func card_selected(card: Card):
	if not state == State.IDLE:
		return
	if card in deck.get_children():
		return
	if card in trash.get_children() and not card == trash.get_children()[-1]:
		return
	if not selected_card:
		selected_card = card
		return
	if selected_card == card:
		return
	state = State.TWEENING
	
	var t : Tween = card.create_tween()
	var t2 : Tween = card.create_tween()
	
	t.tween_property(card, "position", selected_card.position, card.position.distance_to(selected_card.position) * 0.001)
	t2.tween_property(selected_card, "position", card.position, card.position.distance_to(selected_card.position) * 0.001)
	var parents = [selected_card.get_parent(), card.get_parent()]
	card.get_parent().remove_child(card)
	selected_card.get_parent().remove_child(selected_card)
	parents[0].add_child(card)
	parents[1].add_child(selected_card)
	selected_card = null
	await t.finished
	await t2.finished
	if is_dead_end():
		state = State.DEAD_END
		return
	state = State.IDLE


func loop_deck():
	var i=0
	var tweens_to_check = []
	var sounds_to_delete = []
	for card in trash.get_children():
		trash.remove_child(card)
		deck.add_child(card)
	shuffle_cards()
	$DeckLooped.play()
	for card in deck.get_children():
		card.flip()
		var t : Tween = create_tween()
		tweens_to_check.append(t)
		t.tween_property(card, "position", deck_positions + Vector2(0, i), 0.4)
		i -= 1
		await get_tree().create_timer(0.03).timeout
	deck.get_children().reverse()
	for t : Tween in tweens_to_check:
		if t.is_running():
			await t.finished
	
	deck.get_children().reverse()
	state = State.SHUFFLE_FINISHED


func is_dead_end(all_available_cards: Array = []) -> bool:
	if not all_available_cards:
		all_available_cards = board.get_children() + hand.get_children()
		if trash.get_child_count() > 0:
			all_available_cards.append(trash.get_child(trash.get_child_count() - 1))
	
	if len(all_available_cards) < 6:
		return false
	var suit_counts := {}
	for card in all_available_cards:
		var suit = card.suit
		suit_counts[suit] = suit_counts.get(suit, 0) + 1
		if suit_counts[suit] >= 3:
			return false
	return true 
