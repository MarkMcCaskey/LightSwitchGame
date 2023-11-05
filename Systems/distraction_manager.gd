class_name DistractionManager extends Node3D

var last_distraction: Distraction.DistractionType
var last_room: Room.RoomName

# difficulty between 1-3
func generate_distraction(difficulty: int) -> bool:
	match difficulty:
		1:
			var dist = _get_random_new_distraction()
			var room = _get_random_new_room()
			var spawn_group = Room.room_name_to_spawn_group(room)
			var found: bool = false
			var light_group = Room.room_name_to_light_group(room)
			#get_tree().call_group(light_group, "toggle_light", false)
			for spawner in get_tree().get_nodes_in_group(spawn_group):
				if spawner.spawn_object_type(dist):
					found = true
					break
			if found:
				last_distraction = dist
				last_room = room
			return found
		2:
			pass
		_:
			pass
	return false

func _get_random_room() -> Room.RoomName:
	# None (idx 0) is not a valid room
	var room_len = len(Room.RoomName.values()) - 1
	return Room.RoomName.values()[(randi() % room_len) + 1]

func _get_random_new_room() -> Room.RoomName:
	var room_candidate = _get_random_room()
	while room_candidate == last_room:
		room_candidate = _get_random_room()
	return room_candidate

func _get_random_distraction() -> Distraction.DistractionType:
	return Distraction.DistractionType.values()[randi() % len(Distraction.DistractionType.values())]

func _get_random_new_distraction() -> Distraction.DistractionType:
	var dist_candidate = _get_random_distraction()
	while dist_candidate == last_distraction:
		dist_candidate = _get_random_distraction()
	return dist_candidate
