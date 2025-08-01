extends Control

@onready var deck := $Deck
@onready var trash := $Trash
@onready var board := $Board
@onready var hand := $Hand
@onready var card_path := preload("res://card.tscn")

var selected_card : Card
var state : int = State.IDLE
var suits = ["♥️", "♣️", "♦️", "♠️"]

var hand_limit : int = 4


func _ready() -> void:
	
	for i in 18:
		var card_instance : Card = card_path.instantiate()
		card_instance.connect("selected", card_selected)
		card_instance.suit = randi_range(0, 2)
		card_instance.text = ""
		card_instance.position.y += 40 + i
		card_instance.position.x += 10
		deck.add_child(card_instance)
	await updraw()
	#for i in deck.get_children():
		#trash_card(i)
		#await get_tree().create_timer(0.03).timeout
		
func _physics_process(delta: float) -> void:
	if state != State.IDLE:
		return
	if board.get_child_count() < 3 and deck.get_child_count() == 0:
		for c in board.get_children():
			discard(c)
		for c in hand.get_children():
			discard(c)
		return
		
	if board.get_child(0).suit == board.get_child(1).suit and board.get_child(0).suit == board.get_child(2).suit:
		state = State.TWEENING
		for c in board.get_children():
			discard(c)
		await updraw()


func discard(card : Card):
	if selected_card == card:
		selected_card = null
	var t : Tween = card.create_tween()
	card.get_parent().remove_child(card)
	trash.add_child(card)
	var target_position := Vector2(1000, 450 - trash.get_child_count())
	t.tween_property(card, "position", target_position, card.position.distance_to(target_position) * 0.001)


func updraw():
	state = State.TWEENING
	var hand_len := hand.get_child_count()
	var board_len := board.get_child_count()
	
	var board_positions := [
		get_viewport_rect().size / 2 + Vector2(+80, -100),
		get_viewport_rect().size / 2 + Vector2(-70, -100),
		get_viewport_rect().size / 2 + Vector2(-220, -100),
	]
	
	var hand_positions := [
		get_viewport_rect().size / 2 + Vector2(+120, +200),
		get_viewport_rect().size / 2 + Vector2(0, +200),
		get_viewport_rect().size / 2 + Vector2(-120, +200),
		get_viewport_rect().size / 2 + Vector2(-240, +200),
		get_viewport_rect().size / 2 + Vector2(-360, +200),
		get_viewport_rect().size / 2 + Vector2(-480, +200),
		get_viewport_rect().size / 2 + Vector2(-600, +200),
		get_viewport_rect().size / 2 + Vector2(-720, +200),
	]
	
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


func card_selected(card:Card):
	
	if not selected_card:
		selected_card = card
		return
	if selected_card == card:
		return
	state = State.TWEENING
	#if selected_card.get_parent() == card.get_parent():
		#selected_card = card
		#return
	
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
	print('d')
