extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("Idle")

func _on_start_button_pressed() -> void:
	animation_player.play("CameraFly")

func _load_first_level() -> void:
	var first_level = load("res://main.tscn")
	get_tree().change_scene_to_packed(first_level)
