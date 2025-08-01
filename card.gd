@icon("res://editor_icons/Card.png")

extends Button
class_name Card

signal selected(card:Card)

@export var value : int = 2
@export var rank : int = Rank.NUMBER
@export var suit : int = Suit.HEARTS

@onready var label: Label = $Label
@onready var sfx_click: AudioStreamPlayer = $"SFX_Click"

func _ready() -> void:
	pass
	#print(has_node("Label"))
	#print(label.text)

func set_info(s: int, v: int) -> void:
	self.suit = s
	self.value = v
	match value:
		#0: rank.JOKER
		1:
			rank = Rank.ACE
			label.text = "ACE"
		11:
			rank = Rank.JACK
			label.text = "JACK"
		12:
			rank = Rank.QUEEN
			label.text = "QUEEN"
		13:
			rank = Rank.KING
			label.text = "KING"
		_:
			rank = Rank.NUMBER
			label.text = str(value)
	#print(get_info())

func _on_button_up() -> void:
	selected.emit(self)
	sfx_click.play()

func get_value() -> String:
	match value:
		#0: return "JOKER"
		1: return "ACE"
		11: return "JACK"
		12: return "QUEEN"
		13: return "KING"
	return str(value)
	
func get_suit() -> String:
	match suit:
		0: return "HEARTS"
		1: return "CLUBS"
		2: return "DIAMONDS"
		3: return "SPADES"
	return ""
		
func get_info() -> String:
	return get_value() + " of " + get_suit()
