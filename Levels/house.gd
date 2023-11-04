extends Node3D

# A hack because task is in house and I'm just too lazy to move it
signal HouseComplete

func _on_task_task_complete() -> void:
	emit_signal("HouseComplete")
