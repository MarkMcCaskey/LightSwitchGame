extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("Idle")

func _on_start_button_pressed() -> void:
	animation_player.play("CameraFly")
