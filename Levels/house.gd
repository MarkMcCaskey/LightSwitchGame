extends Node3D

# A hack because task is in house and I'm just too lazy to move it
signal HouseComplete

func _on_task_task_complete() -> void:
	emit_signal("HouseComplete")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		body.enter_house()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		body.exit_house()
