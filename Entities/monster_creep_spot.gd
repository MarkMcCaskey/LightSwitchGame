@tool
class_name MonsterCreepSpot extends Node3D

@export var location: Location
enum Location { FrontDoor, BackGarageDoor, BedRoom2Window, BackPorch, BedRoom1Window }

func _ready() -> void:
	if Engine.is_editor_hint():
		var creeper_scene := load("res://Entities/creature_w_1_creeper_breathing.tscn")
		var creeper = creeper_scene.instantiate()
		creeper.scale *= 0.2
		#creeper.modulate.a = 0.5
		add_child(creeper)
