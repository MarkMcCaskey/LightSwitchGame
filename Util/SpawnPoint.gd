class_name SpawnPoint extends Node3D

@export var room: Room.RoomName
@export var spawnable_objects: Array[PackedScene]
@export var distraction_type: Distraction.DistractionType

func _ready() -> void:
	# TODO print warning tree if this condition fails for debugging ease
	assert(room != Room.RoomName.None, "spawn point must have room set")
	assert(spawnable_objects != null && len(spawnable_objects) > 0, "spawn must have something to spawn")
	assert(distraction_type != null)
	var spawn_group = Room.room_name_to_spawn_group(room)
	add_to_group(spawn_group)

func room_active() -> bool:
	for child in get_children():
		if child is Distraction:
			return true
	return false

func spawn_object() -> void:
	var object = spawnable_objects[0].instantiate()
	object.room = room
	object.type = distraction_type
	add_child(object)

func spawn_object_type(dt: Distraction.DistractionType) -> void:
	if distraction_type != dt:
		return
	# TODO: do logic here
