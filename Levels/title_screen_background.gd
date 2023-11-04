extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var settings_menu: SettingsMenu = $Camera3D/SettingsMenu
@onready var camera: Camera3D = $Camera3D
const main_scene = "res://main.tscn"
var settings_open: bool = false

func _ready() -> void:
	settings_menu.hide()
	settings_open = false
	animation_player.play("Idle")
	camera.make_current()

func _unhandled_input(event: InputEvent) -> void:
	if settings_open: return
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

func _on_settings_button_pressed() -> void:
	settings_open = true
	settings_menu.show()

func _on_settings_menu_settings_closed() -> void:
	settings_open = false
	settings_menu.hide()

