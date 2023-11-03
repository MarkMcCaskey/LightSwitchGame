class_name DeathScene extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	animation_player.play("yellout")

func _killed() -> void:
	animation_player.stop()
	print("You died!")
