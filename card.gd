@icon("res://editor_icons/Card.png")

extends Button
class_name Card

signal selected(card:Card)

@export var value : int = 2
@export var rank : int = Rank.NUMBER
@export var suit : int = Suit.HEARTS




func _on_button_up() -> void:
	selected.emit(self)
