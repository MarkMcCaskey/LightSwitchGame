class_name Interactable extends Area3D

@export var interact_text: String = "Interact"

signal on_interact

func interact() -> void:
	#assert(false, "implement me")
	emit_signal("on_interact")

