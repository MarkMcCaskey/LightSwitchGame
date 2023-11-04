class_name WinScene extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera3D = $Camera3D
@onready var label: Label = $Camera3D/Label
@onready var timer: Timer = $Timer

func _ready() -> void:
	ResourceLoader.load_threaded_request("res://Levels/title_screen_background.tscn")
	animation_player.play("mixamo_com")

func _on_timer_timeout() -> void:
	var menu = ResourceLoader.load_threaded_get("res://Levels/title_screen_background.tscn")
	get_tree().change_scene_to_packed(menu)

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	timer.start()
