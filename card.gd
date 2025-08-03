@icon("res://editor_icons/Card.png")

extends Button
class_name Card

signal selected(card:Card)

@export var value : int
@export var rank : int
@export var suit : int

@onready var label_tl: Label = $Base/Label_TL
@onready var label_br: Label = $Base/Label_BR
@onready var suit_icon: Sprite2D = $Base/SuitIcon
@onready var back : Sprite2D = $Base/Back

var suits = ["","♠️","♥️","♣️","♦️"]

@onready var sfx_click: AudioStreamPlayer = $"SFX_Click"

var suit_icons := {
	0: preload("res://JokerHat.png"),
	Suit.SPADES: preload("res://Suit_Spade.png"),
	Suit.HEARTS: preload("res://Suit_Heart.png"),
	Suit.CLUBS: preload("res://Suit_Club.png"),
	Suit.DIAMONDS: preload("res://Suit_Diamond.png"),
}

func _ready() -> void:
	pass
	#print(has_node("Label"))
	#print(label.text)


func set_info(suit: int, rank: int) -> void:
	self.suit = suit
	self.rank = rank
	self.value = rank
	match rank:
		Rank.JACK:
			label_tl.text = "J"
			label_br.text = "J"
		Rank.QUEEN:
			label_tl.text = "Q"
			label_br.text = "Q"
		Rank.KING:
			label_tl.text = "K"
			label_br.text = "K"
		Rank.ACE:
			label_tl.text = "A"
			label_br.text = "A"
		Rank.JOKER:
			label_tl.text = ""
			label_br.text = ""
		_:
			label_tl.text = str(rank)
			label_br.text = str(rank)
	#print(get_info())
	suit_icon.texture = suit_icons[suit]
	if self.suit == Suit.SPADES || self.suit == Suit.CLUBS:
		label_tl.add_theme_color_override("font_color", Color("#1E2749"))
		label_br.add_theme_color_override("font_color", Color("#1E2749"))
	elif self.suit == Suit.HEARTS || self.suit == Suit.DIAMONDS:
		label_tl.add_theme_color_override("font_color", Color("#600724"))
		label_br.add_theme_color_override("font_color", Color("#600724"))
	else: #JOKER
		label_tl.add_theme_color_override("font_color", Color("#600724"))
		label_br.add_theme_color_override("font_color", Color("#1E2749"))
	text = ""


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
	match rank:
		Rank.JACK: return "JACK"
		Rank.QUEEN: return "QUEEN"
		Rank.KING: return "KING"
		Rank.ACE: return "ACE"
		Rank.JOKER: return "JOKER"
	return str(rank)

func get_suit() -> String:
	match suit:
		Suit.SPADES: return "SPADES"
		Suit.HEARTS: return "HEARTS"
		Suit.CLUBS: return "CLUBS"
		Suit.DIAMONDS: return "DIAMONDS"
	return "NONE"

func get_info() -> String:
	return get_value() + " of " + get_suit()
