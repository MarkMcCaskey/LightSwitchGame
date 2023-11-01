extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
const main_scene = "res://main.tscn"

func _ready() -> void:
	animation_player.play("Idle")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("start"):
		_start_game()

func _on_start_button_pressed() -> void:
	_start_game()

func _start_game() -> void:
	ResourceLoader.load_threaded_request(main_scene)
	animation_player.play("CameraFly")

func _load_first_level() -> void:
	var first_level = ResourceLoader.load_threaded_get(main_scene)
	get_tree().change_scene_to_packed(first_level)

func _on_quit_button_pressed() -> void:
	# TODO: confirm prompt
	get_tree().quit()
