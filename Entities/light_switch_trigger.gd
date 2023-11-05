class_name LightSwitchTrigger extends Interactable

@export var room: Room.RoomName

var is_on: bool = false

func interact() -> void:
	is_on = !is_on
	var room_name = Room.room_name_to_light_group(room)
	for node in get_tree().get_nodes_in_group(room_name):
		if node is LightSwitchTrigger:
			continue
		node.toggle_light(is_on)

func toggle_light(v: bool) -> void:
	is_on = v
