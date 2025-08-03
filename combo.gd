extends Node

#@onready var combo_label: Label = $ComboLabel
@onready var score: Control = $"../CanvasLayer/Score"
	
func get_infos(cards: Array) -> String:
	var res=""
	for card in cards:
		res+= card.get_info()+", "
	return res
	
func clean(cards: Array) -> Array:
	var cleans = []
	var jokers_ctr=0
	for card in cards:
		if card.rank == Rank.JOKER:
			jokers_ctr+=1
		else:
			cleans.append(card)
	#print("jokers: "+str(jokers_ctr)+" | "+get_infos(cleans))
	return cleans

# functions below: cards must already be cleaned, free of joker
func same_suit(cards: Array) -> bool:
	for i in range(cards.size()-1):
		if cards[i].suit != cards[i+1].suit:
			return false
	return true

func combo_detector(cards: Array):
	if (combo_royals(cards)):
		#combo_label.text = "Combo: ROYALS!"
		score.add_score(100, "ROYAL$!")
	elif (combo_straight(cards)):
		#combo_label.text = "Combo: STRAIGHT!"
		score.add_score(60, "$TRAIGHT!")
	else:
		score.add_score(30,"")
	await get_tree().create_timer(2.0).timeout
	#combo_label.text = "Combo:"

func combo_royals(cards: Array) -> bool:
	for card in cards:
		if Rank.TWO <= card.rank && card.rank <= Rank.TEN:
			return false
	#print("royals")
	return true

func combo_straight(cards: Array) -> bool:
	var temp = cards
	temp.sort_custom(func(a: Card, b: Card) -> bool:
		return a.value < b.value
	)
	for i in range(temp.size()-1):
		if temp[i].rank >= Rank.TEN || temp[i].value != temp[i+1].value-1:
			return false
	#print("straight")
	return true
