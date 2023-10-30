class_name LightSwitchTrigger extends Interactable

@export var switch_name: String

var is_on: bool = true

func interact() -> void:
	is_on = !is_on
	get_tree().call_group(switch_name + "_lights", "toggle_light", is_on)
