@tool
class_name Door extends Node3D

@export var closed: bool = true:
	get: return closed
	set(val):
		closed = val
		_set_t_dt()
@export var flip_direction: bool = false:
	get: return flip_direction
	set(val):
		flip_direction = val
		_set_t_dt()
enum DoorType { Inner, Outer }
@export var door_type: DoorType

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var door_mesh: MeshInstance3D = $RotationNode/DoorMesh

var t: float = 0 # 0 = closed, 1 = opened
var dt: float = -1 # -1 = closing, +1 = opening

func _set_t_dt() -> void:
	if flip_direction: dt = 1
	else: dt = -1
	if closed:
		t = 0
	else:
		if flip_direction: t = -1
		else: t = 1
		dt *= -1

func _ready() -> void:
	_load_door_mesh()
	animation_tree.active = true

func _process(delta):
	if flip_direction:
		t += delta * dt
		t = clampf(t, -1., 0.)
	else:
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
