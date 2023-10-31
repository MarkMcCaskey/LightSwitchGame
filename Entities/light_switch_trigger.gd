class_name LightSwitchTrigger extends Interactable

@export var room: Room.RoomName

var is_on: bool = true

func interact() -> void:
	is_on = !is_on
	var room_name = Room.room_name_to_light_group(room)
	get_tree().call_group(room_name, "toggle_light", is_on)
