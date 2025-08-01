extends Control

@onready var deck := $Deck
@onready var trash := $Trash
@onready var board := $Board
@onready var hand := $Hand
@onready var card_path := preload("res://card.tscn")

@onready var board_pos: Node2D = $BoardPositions
@onready var hand_pos: Node2D = $HandPositions

@onready var sfx_discard: AudioStreamPlayer2D = $SFX_Discard

var selected_card : Card
var state : int = State.IDLE
var suits = ["♥️", "♣️", "♦️", "♠️"]

var card_vector2 = Vector2(-50, -75)

var hand_limit : int = 4

var board_positions := []
var hand_positions := []
var trash_position := Vector2(982, 428)


func _ready() -> void:
	
	generate_cards()
	shuffle_card()
	var i=0
	for card in deck.get_children():
		card.position.y += 70 + i
		card.position.x += 70
		i+=1
		#print(card.get_info())
		
	board_positions=[]
	for pos in board_pos.get_children():
		board_positions.append(pos.global_position + card_vector2)
	
	hand_positions=[]
	for pos in hand_pos.get_children():
		hand_positions.append(pos.global_position + card_vector2)
	await updraw()


func generate_cards():
	for suit in range (suits.size()):
		for value in range(1,14):
			#var card_instance: Card = Card.new(i, value)
			var card_instance : Card = card_path.instantiate()
			deck.add_child(card_instance)
			card_instance.set_info(suit, value)
			card_instance.connect("selected", card_selected)


func shuffle_card():
	var children = deck.get_children()
	children.shuffle()
	for child in children:
		deck.remove_child(child)
	for child in children:
		deck.add_child(child)


func _physics_process(delta: float) -> void:
	if state != State.IDLE:
		return
	if board.get_child_count() < 3 and deck.get_child_count() == 0:
		discard_many(hand.get_children())
		discard_many(board.get_children())
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
				t.tween_property(card_from_deck, "position", get_viewport_rect().size / 2 + Vector2(-370, -100), 0.7)
				await t.finished
				break
		print()
		discard_many(board.get_children())
		await updraw()
		return
		
	if board.get_child(0).suit == board.get_child(1).suit and board.get_child(0).suit == board.get_child(2).suit:
		state = State.TWEENING
		discard_many(board.get_children())
		await updraw()


func discard_many(cards: Array):
	var sorted = []
	for card in cards:
		var dist = card.position.distance_to(trash_position)
		sorted.append([dist, card])
	sorted.sort()

	for c in sorted:
		var card = c[1]
		discard_one(card)


func discard_one(card: Card):
	if selected_card == card:
		selected_card = null
	var t : Tween = card.create_tween()
	card.get_parent().remove_child(card)
	trash.add_child(card)
	var target_position := Vector2(trash_position.x, trash_position.y - trash.get_child_count())
	t.tween_property(card, "position", target_position, card.position.distance_to(target_position) * 0.001)
	sfx_discard.play()


func updraw():
	state = State.TWEENING
	var hand_len := hand.get_child_count()
	var board_len := board.get_child_count()
	
	var tweens_to_check = []
	
	for i in 3 - board_len:
		if deck.get_child_count() == 0:
			break
		var t : Tween = create_tween()
		tweens_to_check.append(t)
		var card = deck.get_child(0)
		card.text = suits[card.suit]
		deck.remove_child(card)
		board.add_child(card)
		t.tween_property(card, "position", board_positions[i], 0.4)
		await get_tree().create_timer(0.03).timeout
		
	for i in hand_limit - hand_len:
		if deck.get_child_count() == 0:
			break
		var t : Tween = create_tween()
		tweens_to_check.append(t)
		var card = deck.get_child(0)
		card.text = suits[card.suit]
		deck.remove_child(card)
		hand.add_child(card)
		t.tween_property(card, "position", hand_positions[i], 0.4)
		await get_tree().create_timer(0.03).timeout
	
	for t : Tween in tweens_to_check:
		await t.finished
	state = State.IDLE


func card_selected(card: Card):
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
	state = State.IDLE
