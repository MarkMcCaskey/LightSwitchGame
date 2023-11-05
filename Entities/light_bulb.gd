class_name LightBulb extends Node3D

@export var room: Room.RoomName

@onready var light: SpotLight3D = $SpotLight3D
# TODO: export, etc
var is_on: bool = false:
	get: return is_on
	set(v):
		if v:
			light.show()
		else:
			light.hide()
		is_on = v

func _ready() -> void:
	assert(room != Room.RoomName.None)
	var room_name = Room.room_name_to_light_group(room)
	add_to_group(room_name)
	add_to_group("lights")
	if is_on:
		light.show()
	else:
		light.hide()

func toggle_light(new_state: bool) -> void:
	if is_on == new_state:
		return
	is_on = new_state
