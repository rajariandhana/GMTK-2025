extends Control

@onready var message: Label = $Message
@onready var dollar: Label = $Dollar
@onready var score_text: Label = $ScoreText
@onready var timer: Timer = $Timer
@onready var final_score: Label = $FinalScore
@onready var invisible_layer: ColorRect = $"../InvisibleLayer"

var timer_flipper: bool

var game_score: int

func _ready():
	timer.start()
	timer_flipper=false
	reset_score()

func reset_score():
	game_score=0
	message.visible = false
	dollar.visible = true
	score_text.visible = true
	final_score.text = ""
	invisible_layer.visible = false
	update_score_display()

func add_score(num: int, combo_message: String):
	game_score += num
	if(combo_message!=""):
		#print("here")
		message.text = combo_message
		message.visible = true
		dollar.visible = false
		score_text.visible = false
		await get_tree().create_timer(1.5).timeout
		message.visible = false
		dollar.visible = true
		score_text.visible = true
		update_score_display()
	else:
		update_score_display()
	
func update_score_display():
	score_text.text = str(game_score)

func get_score()->int:
	return game_score

func endgame():
	message.text = "GAME ENDS"
	message.visible = true
	dollar.visible = false
	score_text.visible = false
	final_score.text = "SCORE: "+str(game_score)
	invisible_layer.visible = true

func _on_timer_timeout() -> void:
	if timer_flipper:
		dollar.add_theme_color_override("font_color", Color("#E9B003"))
		score_text.add_theme_color_override("font_color", Color("#E9B003"))
	else:
		dollar.add_theme_color_override("font_color", Color("#FFD700"))
		score_text.add_theme_color_override("font_color", Color("#FFD700"))
	timer_flipper = !timer_flipper
		
