class_name Distraction extends Node3D

@export var room: Room.RoomName

var timer: Timer
var lights_on: bool = false

func _ready() -> void:
	var room_name = Room.room_name_to_light_group(room)
	lights_on = false
	# TODO: might need get_tree().root here
	for node in get_tree().get_nodes_in_group(room_name):
		if node.is_on:
			lights_on = true
		else:
			if lights_on:
				push_warning("Lights do not all share a state in room/group " + room_name)
	
	timer = Timer.new()
	timer.one_shot = true
	timer.stop()
	timer.wait_time = 10.
	timer.timeout.connect(_timer_timed_out)
	add_child(timer)
	add_to_group(room_name)

	if lights_on:
		timer.start()


func toggle_light(new_state: bool) -> void:
	if new_state == lights_on:
		return
	lights_on = new_state
	if lights_on:
		timer.start()
	else:
		timer.stop()

func _timer_timed_out() -> void:
	queue_free()
