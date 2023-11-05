class_name LightSwitchTrigger extends Interactable

@export var room: Room.RoomName

@onready var is_on: bool = false

func _ready() -> void:
	call_deferred("_setup")
	do_set()

func _setup() -> void:
	await get_tree().physics_frame

func interact() -> void:
	is_on = !is_on
	do_set()

func do_set() -> void:
	var room_name = Room.room_name_to_light_group(room)
	for node in get_tree().get_nodes_in_group(room_name):
		if node is LightSwitchTrigger:
			continue
		node.toggle_light(is_on)
 
func toggle_light(v: bool) -> void:
	is_on = v
