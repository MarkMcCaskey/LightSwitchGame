@tool
class_name Door extends Node3D

@export var closed: bool = true:
	get: return closed
	set(val):
		closed = val
		if closed:
			t = 0
			dt = -1
		else:
			t = 1
			dt = 1
enum DoorType { Inner, Outer }
@export var door_type: DoorType

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var door_mesh: MeshInstance3D = $RotationNode/DoorMesh

var t: float = 0 # 0 = closed, 1 = opened
var dt: float = -1 # -1 = closing, +1 = opening

func _ready() -> void:
	_load_door_mesh()
	animation_tree.active = true

func _process(delta):
	t += delta * dt
	t = clampf(t, 0., 1.)
	animation_tree["parameters/Open/blend_position"] = t

func _load_door_mesh() -> void:
	match door_type:
		DoorType.Outer:
			door_mesh.mesh = load("res://Entities/Objects/Resources/outer_door.tres")
			var material = load("res://Entities/Objects/Resources/outer_door_texture.tres")
			door_mesh.set_surface_override_material(0, material)
		_:
			door_mesh.mesh = load("res://Entities/Objects/Resources/inner_door.tres")
			var material = load("res://Entities/Objects/Resources/inner_door_texture.tres")
			door_mesh.set_surface_override_material(0, material)


func _on_door_interactable_on_interact() -> void:
	dt = -dt
