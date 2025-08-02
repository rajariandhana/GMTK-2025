@icon("res://editor_icons/Card.png")

extends Button
class_name Card

signal selected(card:Card)

@export var value : int = 2
@export var rank : int = Rank.NUMBER
@export var suit : int = Suit.HEARTS

@onready var label_tl: Label = $Base/Label_TL
@onready var label_br: Label = $Base/Label_BR
@onready var suit_icon: Sprite2D = $Base/SuitIcon
@onready var back : Sprite2D = $Base/Back

var suits = ["♥️", "♣️", "♦️", "♠️"]

@onready var sfx_click: AudioStreamPlayer = $"SFX_Click"

var suit_icons := {
	Suit.HEARTS: preload("res://Suit_Heart.png"),
	Suit.CLUBS: preload("res://Suit_Club.png"),
	Suit.DIAMONDS: preload("res://Suit_Diamond.png"),
	Suit.SPADES: preload("res://Suit_Spade.png"),
}


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
			label_tl.text = "A"
			label_br.text = "A"
		11:
			rank = Rank.JACK
			label_tl.text = "J"
			label_br.text = "J"
		12:
			rank = Rank.QUEEN
			label_tl.text = "Q"
			label_br.text = "Q"
		13:
			rank = Rank.KING
			label_tl.text = "K"
			label_br.text = "K"
		_:
			rank = Rank.NUMBER
			label_tl.text = str(value)
			label_br.text = str(value)
	#print(get_info())
	suit_icon.texture = suit_icons[suit]
	if self.suit == Suit.SPADES || self.suit == Suit.CLUBS:
		label_tl.add_theme_color_override("font_color", Color("#1E2749"))
		label_br.add_theme_color_override("font_color", Color("#1E2749"))
	elif self.suit == Suit.HEARTS || self.suit == Suit.DIAMONDS:
		label_tl.add_theme_color_override("font_color", Color("#600724"))
		label_br.add_theme_color_override("font_color", Color("#600724"))


func _on_button_up() -> void:
	selected.emit(self)
	sfx_click.play()


func flip() -> void:
	var t := create_tween()
	t.tween_property($Base, "scale", Vector2(0, scale.y), 0.3)
	await t.finished
	back.visible = not back.visible
	var t2 := create_tween()
	t2.tween_property($Base, "scale", Vector2(1, scale.y), 0.3)


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
