class_name GenericTrigger extends Node3D

@export var trigger_name: String

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("body entered by " + body.name)
	if body is Player:
		body.speed = 20
