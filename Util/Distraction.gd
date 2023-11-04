class_name Distraction extends Node3D

enum DistractionType { Unique, BodyBag, Scarecrow }

@export var room: Room.RoomName
@export var type: DistractionType
@export var stare_at_player: bool = false
@export var base_distraction_xp: float = Settings.monster_distraction_xp_amount
@export var base_distraction_multiplier: float = 1.32

var audio_player: AudioStreamPlayer3D
var player: Player = null
var kill_timer: Timer
var audio_timer: Timer
var xp_timer: Timer
# ligths on
var is_on: bool = false
var idle_audio_sounds: Array[AudioStream] = []
var last_played_idle_audio_noise: int = -1

@onready var distraction_xp: float = base_distraction_xp

func _ready() -> void:
	var room_name = Room.room_name_to_light_group(room)
	is_on = false
	# TODO: might need get_tree().root here
	for node in get_tree().get_nodes_in_group(room_name):
		if node.is_on:
			is_on = true
		else:
			if is_on:
				push_warning("Lights do not all share a state in room/group " + room_name)
	audio_player = AudioStreamPlayer3D.new()
	#audio_player.max_db = -10
	#audio_player.max_distance = 30
	audio_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
	add_child(audio_player)
	
	kill_timer = Timer.new()
	kill_timer.one_shot = true
	kill_timer.stop()
	kill_timer.wait_time = 10.
	kill_timer.timeout.connect(_kill_timer_timed_out)
	add_child(kill_timer)
		
	audio_timer = Timer.new()
	audio_timer.one_shot = true
	audio_timer.stop()
	audio_timer.wait_time = 3.0
	audio_timer.timeout.connect(_audio_timer_timed_out)
	add_child(audio_timer)
	
	xp_timer = Timer.new()
	xp_timer.one_shot = true
	xp_timer.stop()
	xp_timer.wait_time = randf_range(5.0, 10.0)
	xp_timer.timeout.connect(_xp_timer_timed_out)
	add_child(xp_timer)
	
	add_to_group(room_name)
	add_to_group("distractions")

	if is_on:
		kill_timer.start()
	
	if stare_at_player:
		player = get_tree().get_first_node_in_group("Player")
	
	# TODO: maybe call deferred?
	_init_idle_audio_sounds()
	audio_player.connect("finished", _audio_finished_handler)
	_play_intro_audio()

func _init_idle_audio_sounds() -> void:
	match type:
		Distraction.DistractionType.BodyBag:
			idle_audio_sounds = [
				load("res://Assets/Audio/qubodup-GhostMoan01.ogg"),
				load("res://Assets/Audio/qubodup-GhostMoan02.ogg"),
				load("res://Assets/Audio/qubodup-GhostMoan03.ogg"),
				load("res://Assets/Audio/qubodup-GhostMoan04.ogg")
			]
		Distraction.DistractionType.Scarecrow:
			pass
		_:
			pass

func _process(_delta: float) -> void:
	if stare_at_player && player:
		var old_x = rotation.x
		look_at(player.global_transform.origin, Vector3.UP)
		rotation.x = old_x

func toggle_light(new_state: bool) -> void:
	if new_state == is_on:
		return
	is_on = new_state
	if is_on:
		kill_timer.paused = false
		kill_timer.start()
	else:
		kill_timer.stop()

func _kill_timer_timed_out() -> void:
	queue_free()

func _play_intro_audio() -> void:
	match type:
		Distraction.DistractionType.BodyBag:
			var intro_sound = load("res://Assets/Audio/ghostbreath.ogg")
			audio_player.stream = intro_sound
		Distraction.DistractionType.Scarecrow:
			pass
		_:
			pass
	audio_player.play()

func _select_random_idle_audio() -> int:
	if len(idle_audio_sounds) == 0: return -1
	if len(idle_audio_sounds) == 1: return 0
	if len(idle_audio_sounds) == 2:
		if last_played_idle_audio_noise == 1: return 0
		else: return 1
	var candidate = randi() % len(idle_audio_sounds)
	while candidate == last_played_idle_audio_noise:
		candidate = randi() % len(idle_audio_sounds)
	return candidate

func _play_idle_audio() -> void:
	var idx: int = _select_random_idle_audio()
	#print("PLaying audio at index: " + str(idx))
	if idx == -1: return
	audio_player.stream = idle_audio_sounds[idx]
	last_played_idle_audio_noise = idx
	audio_player.play()

func _audio_finished_handler() -> void:
	var new_wait_time: float = randf_range(1.3, 8.9)
	#print("audio finished! waiting for " + str(new_wait_time) +  " seconds")
	audio_timer.paused = false
	audio_timer.start(new_wait_time)

func _audio_timer_timed_out() -> void:
	_play_idle_audio()

func _add_xp() -> void:
	var monster = get_tree().get_first_node_in_group("")
	if monster:
		monster.add_xp(distraction_xp)
		distraction_xp = distraction_xp * base_distraction_multiplier

func _xp_timer_timed_out() -> void:
	_add_xp()
	xp_timer.start(randf_range(3.192, 15.9))
