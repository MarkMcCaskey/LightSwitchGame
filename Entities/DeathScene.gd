class_name DeathScene extends Node3D

signal StaticTriggered

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera3D = $Camera3D
@onready var timer: Timer = $Timer

func _ready() -> void:
	ResourceLoader.load_threaded_request("res://Levels/title_screen_background.tscn")
	animation_player.play("yellout")

func _killed() -> void:
	print("You died!")
	timer.start()

func _on_timer_timeout() -> void:
	var menu = ResourceLoader.load_threaded_get("res://Levels/title_screen_background.tscn")
	get_tree().change_scene_to_packed(menu)

func _static_triggered() -> void:
	emit_signal("StaticTriggered")
