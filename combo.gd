extends Node

@onready var combo_label: Label = $ComboLabel

func same_suit(cards: Array) -> bool:
	for i in range(cards.size()-1):
		if cards[i].suit != cards[i+1].suit:
			return false
	return true

# @requires cards must be 3 of same suit since will only be called when discarding 3
func combo_detector(cards: Array):
	#print("detecting")
	if (royals(cards)):
		combo_label.text = "Combo: ROYALS!"
	elif (numbers(cards) && straight(cards)):
		combo_label.text = "Combo: STRAIGHT!"
	await get_tree().create_timer(2.0).timeout
	combo_label.text = "Combo:"

func royals(cards: Array) -> bool:
	for card in cards:
		if !royal(card):
			return false
	print("royals")
	return true
	
func royal(card: Card) -> bool:
	if card.rank == Rank.JACK || card.rank == Rank.QUEEN || card.rank == Rank.KING:
		return true
	return false

func numbers(cards: Array) -> bool:
	for card in cards:
		if card.rank != Rank.NUMBER:
			return false
	print("numbers")
	return true

func straight(cards: Array) -> bool:
	var temp = cards
	temp.sort_custom(func(a: Card, b: Card) -> bool:
		return a.value < b.value
	)
	for i in range(temp.size()-1):
		if temp[i].value != temp[i+1].value-1:
			return false
	print("straight")
	return true
