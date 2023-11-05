class_name HowToPlay extends Control

signal HowToPlayQuit

func _on_back_button_pressed() -> void:
	emit_signal("HowToPlayQuit")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		emit_signal("HowToPlayQuit")
