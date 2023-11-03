@tool

class_name SpawnPoint extends Node3D

@export var room: Room.RoomName
@export var spawnable_objects: Array[PackedScene]
@export var distraction_type: Distraction.DistractionType

func _ready() -> void:
	# TODO print warning tree if this condition fails for debugging ease
	#assert(room != Room.RoomName.None, "spawn point must have room set")
	#assert(spawnable_objects != null && len(spawnable_objects) > 0, "spawn must have something to spawn")
	#assert(distraction_type != null)
	if Engine.is_editor_hint():
		if spawnable_objects && len(spawnable_objects) > 0:
			var distraction = spawnable_objects[1].instantiate()
			#creeper.scale *= 0.2
			#creeper.modulate.a = 0.5
			add_child(distraction)
	else:
		var spawn_group = Room.room_name_to_spawn_group(room)
		add_to_group(spawn_group)

func room_active() -> bool:
	for child in get_children():
		if child is Distraction:
			return true
	return false

func _random_object() -> PackedScene:
	return spawnable_objects[randi() % len(spawnable_objects)]

func spawn_object() -> void:
	var object = _random_object().instantiate()
	object.room = room
	object.type = distraction_type
	print("Object of type " + Distraction.DistractionType.keys()[distraction_type] + " spawned in room " + Room.RoomName.keys()[room])
	add_child(object)

func spawn_object_type(dt: Distraction.DistractionType) -> bool:
	if distraction_type != dt:
		return false
	spawn_object()
	return true

func _get_configuration_warnings() -> PackedStringArray:
	var out: Array[String] = []
	if room == Room.RoomName.None:
		out.append("Spawn point must have room set!")
	if spawnable_objects == null || len(spawnable_objects) == 0:
		out.append("Spawn point must have something to spawn")
	if distraction_type == null:
		out.append("Distraction type must be set on spawn point")
	return PackedStringArray(out)
