class_name PauseMenu extends Control

signal PauseMenuClosed

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		emit_signal("PauseMenuClosed")
 
func _on_unpause_button_pressed() -> void:
	# needed for web
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	emit_signal("PauseMenuClosed")

func _on_menu_button_pressed() -> void:
	var title = load("res://Levels/title_screen_background.tscn")
	get_tree().paused = false
	get_tree().change_scene_to_packed(title)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
