extends Panel
@onready var pause_panel: Panel = $"."
@onready var click: AudioStreamPlayer2D = $Click

func _ready() -> void:
	pause_panel.visible=false

func resume():
	pause_panel.visible=false
	get_tree().paused = false
	#animation_player.play_backwards("blur")
	print("GAME RESUMED")
	click.play()
	
func pause():
	click.play()
	pause_panel.visible=true
	get_tree().paused = true
	#animation_player.play("blur")
	print("GAME PAUSED")

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()
	print("GAME RESTARTED")

func _on_main_menu_pressed() -> void:
	click.play()
	#get_tree().quit() -> this function will quit application
	print("GO TO MAIN MENU (not configured yet)")
