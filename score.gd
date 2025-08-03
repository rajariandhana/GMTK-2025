extends Control

@onready var dollar: Label = $Dollar
@onready var score_text: Label = $ScoreText
@onready var timer: Timer = $Timer

var timer_flipper: bool

var game_score: int

func _ready():
	timer.start()
	timer_flipper=false

func reset_score():
	game_score=0
	update_score_display()

func add_score(num: int):
	game_score += num
	update_score_display()
	
func update_score_display():
	score_text.text = str(game_score)

func get_score()->int:
	return game_score


func _on_timer_timeout() -> void:
	if timer_flipper:
		dollar.add_theme_color_override("font_color", Color("#E9B003"))
		score_text.add_theme_color_override("font_color", Color("#E9B003"))
	else:
		dollar.add_theme_color_override("font_color", Color("#FFD700"))
		score_text.add_theme_color_override("font_color", Color("#FFD700"))
	timer_flipper = !timer_flipper
		
