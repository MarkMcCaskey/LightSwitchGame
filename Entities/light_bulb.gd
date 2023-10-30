class_name LightBulb extends Node3D

@export var switch_name: String

@onready var light: SpotLight3D = $SpotLight3D
# TODO: export, etc
var is_on: bool = true

func _ready() -> void:
	assert(switch_name)
	add_to_group(switch_name + "_lights")

func toggle_light(new_state: bool) -> void:
	if is_on == new_state:
		return
	is_on = new_state
	if is_on:
		light.show()
	else:
		light.hide()
