class_name SpawnPoint extends Node3D

@export var room: Room.RoomName
@export var spawned_object: PackedScene

func _ready() -> void:
	# TODO print warning tree if this condition fails for debugging ease
	assert(room != Room.RoomName.None, "spawn point must have room set")
	assert(spawned_object != null, "spawn must have something to spawn")
	var spawn_group = Room.room_name_to_spawn_group(room)
	add_to_group(spawn_group)

func room_active() -> bool:
	for child in get_children():
		if child is Distraction:
			return true
	return false

func spawn_object() -> void:
	var object = spawned_object.instantiate()
	object.room = room
	add_child(object)
