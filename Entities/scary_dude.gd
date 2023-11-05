class_name ScaryDude extends CharacterBody3D

signal ScaryDudeSafetyLevelChanged(old: int, new: int)

enum State { Hunting, Creeping, Idle, InHouse, EnteringHouse, MovingBetweenCreepSpots }

@export var state: State = State.Creeping:
	get: return state
	set(val):
		if val == State.Hunting || val == State.InHouse || State.MovingBetweenCreepSpots:
			if pathfinding_fix_timer:
				position_at_last_timeout = global_position
				pathfinding_fix_timer.start(path_finding_check_time)
		state = val

@export var speed: float = 4.6
@export var base_move_chance: int = Settings.monster_move_chance
@export var base_monster_aggression: float = Settings.monster_agression
# used for debugging
@export var can_kill_player: bool = true
@export var target_location: Vector3 = Vector3(0.,0.,0.):
	get:
		return target_location
	set(value):
		target_location = value
		if navigation_agent:
			navigation_agent.target_position = value

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var animated_creature: AnimatedCreature1 = $AnimatedCreature1
@onready var monster_vision: Camera3D = $BoneAttachment3D/MonsterVision
@onready var creep_timer: Timer = $CreepTimer
@onready var pathfinding_fix_timer: Timer = $PathFindingFixTimer
@onready var outside_bloodlust_timer: Timer = $OutsideBloodLustTimer
const path_finding_check_time: float = 2.0
@onready var movement_audio: AudioStreamPlayer3D = $MovementAudio
@onready var passive_audio: AudioStreamPlayer3D = $PassiveAudio
@onready var sfx_audio: AudioStreamPlayer3D = $SfxAudio
@onready var major_event_audio: AudioStreamPlayer3D = $MajorEventAudio

@onready var monster_aggression: float = base_monster_aggression
@onready var move_chance: int = base_move_chance
@onready var is_seen_by_player: bool = false

@onready var direction: Vector3 = Vector3(0,0,0)
@onready var creep_location: MonsterCreepSpot.Location = MonsterCreepSpot.Location.ColDeSacMiddle
@onready var current_level: int = 0
@onready var current_xp: float = 0
@onready var xp_to_next_level: float = 5
@onready var is_in_the_house: bool = false
@onready var player_inside: bool = true

@onready var position_at_last_timeout: Vector3 = global_position

var player_target: Player

const level_up_sfx: Array[AudioStream] = [
	preload("res://Assets/Audio/ambience-1.ogg"),
	preload("res://Assets/Audio/ambience-2.ogg"),
	preload("res://Assets/Audio/ambience-3.ogg"),
	preload("res://Assets/Audio/ambience-4.ogg")
]
var last_level_up_sfx_idx: int = -1
const aggressive_idle_sfx: Array[AudioStream] = [
	preload("res://Assets/Audio/troll-idle-noises-01.ogg"),
	preload("res://Assets/Audio/troll-idle-noises-02.ogg"),
	preload("res://Assets/Audio/troll-idle-noises-03.ogg"),
	preload("res://Assets/Audio/troll-idle-noises-04.ogg"),
	preload("res://Assets/Audio/troll-idle-noises-05.ogg"),
	preload("res://Assets/Audio/troll-idle-noises-06.ogg"),
	preload("res://Assets/Audio/troll-idle-noises-07.ogg")
]
var last_agressive_idle_sfx_idx: int = -1
const less_aggressive_idle_sfx: Array[AudioStream] = [
	preload("res://Assets/Audio/Beast Growl 1.ogg"),
	preload("res://Assets/Audio/Beast Growl 2.ogg"),
	preload("res://Assets/Audio/Beast Growl 3.ogg"),
	preload("res://Assets/Audio/Beast Growl 4.ogg"),
	preload("res://Assets/Audio/Beast Growl 5.ogg")
]
var last_less_agressive_idle_sfx_idx: int = -1

@onready var position_2_seconds_ago: Vector3 = global_position

const monster_entered_house_audio = preload("res://Assets/Audio/theircoming3.ogg")

func _ready():
	monster_vision.add_to_group("monster_vision")
	#animation_tree.active = true

	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	
	navigation_agent.path_desired_distance = 1.0
	navigation_agent.target_desired_distance = 1.0
	#if target_location == Vector3.ZERO:
		#target_location = collision_shape.global_transform.origin

	navigation_agent.velocity_computed.connect(_on_nav_velocity_computed)
	navigation_agent.max_speed = speed
	player_target = get_tree().get_nodes_in_group("Player")[0]
	if state == State.Creeping:
		_update_location_to_creep_spot(false)
		creep_timer.start()
	_monster_look_at_player()
	target_location = player_target.global_position

func _monster_look_at_player() -> void:
	if player_target:
		var old_x := rotation.x
		look_at(player_target.global_position + Vector3(0, 1.2, 0), Vector3.UP)
		rotation.x = old_x

func _physics_process(delta: float) -> void:
	if is_seen_by_player:
		add_xp(delta * Settings.monster_vision_xp)
	match state:
		State.Idle:
			move_and_slide()
			pass
		State.Hunting:
			_monster_look_at_player()
			if player_target:
				target_location = player_target.global_position
			_nav_physics_process(delta)
		State.Creeping:
			_monster_look_at_player()
			_creep_physics_process(delta)
			move_and_slide()
		State.InHouse:
			_monster_look_at_player()
			if player_target:
				target_location = player_target.global_position
			_nav_physics_process(delta)
		State.EnteringHouse:
			move_and_slide()
			return
		State.MovingBetweenCreepSpots:
			_nav_physics_process(delta, true)
	#if velocity == Vector3.ZERO:
	#velocity = Vector3(1., 0., 1.)
	#move_and_slide()
	#update_animation()
	#update_facing_direction()

func _nav_physics_process(_delta: float, look_at_next_position = false) -> void:
	if !navigation_agent.is_navigation_finished():
		var current_agent_position: Vector3 = collision_shape.global_transform.origin
		var next_path_position: Vector3 = navigation_agent.get_next_path_position()
		if look_at_next_position:
			look_at(next_path_position, Vector3.UP)

		var new_velocity: Vector3 = next_path_position - current_agent_position
		#print("Next position = " + str(next_path_position) + "; " + str(new_velocity))
		direction = new_velocity.normalized()
	else:
		direction = Vector3(0., 0., 0.)
		animated_creature.breakdance()
	
	var next_velocity: Vector3 = velocity
	if direction.x != 0: #&& state_machine.can_move():
		next_velocity.x = direction.x * speed
	else:
		next_velocity.x = move_toward(velocity.x, 0, speed)
	if direction.z != 0: # state_machine.can_move():
		next_velocity.z = direction.z * speed
	else:
		next_velocity.z = move_toward(next_velocity.z, 0, speed)
	if direction.y != 0: # state_machine.can_move():
		next_velocity.y = direction.y * speed
	else:
		next_velocity.y = move_toward(next_velocity.y, 0, speed)
	
	navigation_agent.set_velocity(next_velocity)
	if navigation_agent.is_navigation_finished():
		velocity = next_velocity * _delta
	#velocity = next_velocity

func _creep_physics_process(_delta: float) -> void:
	pass

func _on_nav_velocity_computed(safe_velocity: Vector3) -> void:
	#print(str(velocity) + " -> " + str(safe_velocity) + "; ")
	velocity = safe_velocity
	move_and_slide()

func seen_by_player() -> void:
	is_seen_by_player = true
	#speed = 0.5

func end_seen_by_player() -> void:
	is_seen_by_player = false
	#animated_creature.crouch()
	#speed = 10.0

func add_xp(xp: float) -> void:
	xp = xp * Settings.monster_xp_multiplier
	current_xp += xp
	if current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		current_level += 1
		xp_to_next_level = ceilf(xp_to_next_level * 1.3)
		_on_level_up()

func _on_level_up() -> void:
	var sfx_idx: int = _get_new_rand_level_up_sfx_idx()
	last_level_up_sfx_idx = sfx_idx
	sfx_audio.stream = level_up_sfx[sfx_idx]
	sfx_audio.play()
	if move_chance <= 1:
		move_chance += 1
	elif (current_level % Settings.monster_move_chance_denom) == 0:
		move_chance += 1

func _get_rand_level_up_sfx_idx() -> int:
	return randi_range(0, len(level_up_sfx) -1)

func _get_new_rand_level_up_sfx_idx() -> int:
	var candidate: int = _get_rand_level_up_sfx_idx()
	while candidate == last_level_up_sfx_idx:
		candidate = _get_new_rand_level_up_sfx_idx()
	return candidate

func _get_rand_aggressive_sfx_idx() -> int:
	return randi_range(0, len(aggressive_idle_sfx) -1)

func _get_new_rand_aggressive_sfx_idx() -> int:
	var candidate: int = _get_rand_aggressive_sfx_idx()
	while candidate == last_agressive_idle_sfx_idx:
		candidate = _get_new_rand_aggressive_sfx_idx()
	return candidate
	
func _get_rand_less_aggressive_sfx_idx() -> int:
	return randi_range(0, len(less_aggressive_idle_sfx) -1)

func _get_new_rand_less_aggressive_sfx_idx() -> int:
	var candidate: int = _get_rand_less_aggressive_sfx_idx()
	while candidate == last_less_agressive_idle_sfx_idx:
		candidate = _get_new_rand_less_aggressive_sfx_idx()
	return candidate

func _update_location_to_creep_spot(smooth: bool) -> void:
	var creep_node = get_tree().get_first_node_in_group(MonsterCreepSpot.get_group_name(creep_location))
	assert(creep_node is MonsterCreepSpot, "at " + MonsterCreepSpot.Location.keys()[creep_location])
	if smooth:
		var tween := get_tree().create_tween()
		var distance := global_position.distance_to(creep_node.global_position)
		var time_to_arrive := distance / speed
		tween.tween_property(self, "global_position", creep_node.global_position, time_to_arrive).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "global_rotation", creep_node.global_rotation, time_to_arrive).set_ease(Tween.EASE_IN_OUT)
	else:
		global_position = creep_node.global_position
		global_rotation = creep_node.global_rotation

func _go_to_next_creep_spot() -> void:
	var creep_node = get_tree().get_first_node_in_group(MonsterCreepSpot.get_group_name(creep_location))
	var current = creep_location
	var next: MonsterCreepSpot.Location = MonsterCreepSpot.get_next_location_random(creep_location)
	creep_location = next
	print("Going from " + MonsterCreepSpot.Location.keys()[current]  + " to " + MonsterCreepSpot.Location.keys()[next])
	var old_safety_level = MonsterCreepSpot.safety_rating(current)
	var new_safety_level = MonsterCreepSpot.safety_rating(next)
	if old_safety_level != new_safety_level:
		emit_signal("ScaryDudeSafetyLevelChanged", old_safety_level, new_safety_level)
	
	var should_play_audio: int = randi_range(1, 10)
	if should_play_audio <= 7:
		if new_safety_level <= 2:
			var idx := _get_new_rand_aggressive_sfx_idx()
			last_agressive_idle_sfx_idx = idx
			movement_audio.volume_db = -10
			movement_audio.stream = aggressive_idle_sfx[idx]
			movement_audio.play()
		elif new_safety_level <= 3:
			var idx := _get_new_rand_less_aggressive_sfx_idx()
			last_less_agressive_idle_sfx_idx = idx
			movement_audio.volume_db = -10
			movement_audio.stream = less_aggressive_idle_sfx[idx]
			movement_audio.play()
	
	if MonsterCreepSpot.is_on_same_level(current, next):
		state = State.MovingBetweenCreepSpots
		target_location = creep_node.global_position
	else:
		_update_location_to_creep_spot(true)

func _enter_house_behavior_change() -> void:
	is_in_the_house = true
	var group_name := MonsterCreepSpot.get_group_name(creep_location)
	var spot := get_tree().get_first_node_in_group(group_name)
	var enter_house_position: Node3D = spot.enter_house_position
	assert(enter_house_position)
	state = State.EnteringHouse
	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", enter_house_position.global_position, 1.0)
	tween.tween_callback(_house_entered)

func _house_entered() -> void:
	state = State.InHouse
	major_event_audio.stream = monster_entered_house_audio
	major_event_audio.max_db = -10
	major_event_audio.play()

func _on_creep_timer_timeout() -> void:
	if state == State.MovingBetweenCreepSpots:
		# this shouldn't happen but you know
		creep_timer.start()
		return
	if state != State.Creeping:
		return
	var n: int = randi_range(1, 20)
	print("Timer! Rolled a " + str(n))
	if move_chance >= n:
		if MonsterCreepSpot.can_begin_attack(creep_location) && can_kill_player:
			_enter_house_behavior_change()
			print("Monster has entered the house!")
			return
		else:
			_go_to_next_creep_spot()
	creep_timer.start()

func _on_shoo_away_box_on_interact() -> void:
	_go_to_next_creep_spot()
	creep_timer.start()

func stop_monster_sounds() -> void:
	# TODO: fade it out later
	movement_audio.stop()
	passive_audio.stop()
	sfx_audio.stop()

const epsilon: float = 0.0001
func _positions_approx_equal() -> bool:
	var difference := global_position - position_at_last_timeout
	return (abs(difference.x) < epsilon) && (abs(difference.y) < epsilon) && (abs(difference.z) < epsilon)

func _on_path_finding_fix_timer_timeout() -> void:
	if !(state == State.Hunting || state == State.InHouse || state == State.MovingBetweenCreepSpots):
		return
	pathfinding_fix_timer.start(path_finding_check_time)
	if navigation_agent.is_navigation_finished():
		position_at_last_timeout = global_position
		return
	if _positions_approx_equal():
		if state == State.Hunting:
			print("Stuck hunting! teleport to creep spot?")
		elif state == State.InHouse:
			print("Stuck in house, teleport behind player? This should be its own mode")
		elif state == State.MovingBetweenCreepSpots:
			print("Stuck moving between creep spots!")
		else:
			assert(false, "stuck in state " + State.keys()[state])
	position_at_last_timeout = global_position

func _on_kill_zone_body_entered(body: Node3D) -> void:
	if body is Player:
		body.kill_by(self)

func notify_player_outside() -> void:
	player_inside = false
	var factor: float = 1.0
	var dist: float = global_position.distance_to(player_target.global_position)
	if dist < 10.:
		factor = 3.0
	elif dist < 20.:
		factor = 2.0
	elif dist < 30.:
		factor = 1.0
	else:
		factor = 0.7
	outside_bloodlust_timer.start(randf_range(1.3, 12.9) / factor)

func _find_closest_creep_spot() -> MonsterCreepSpot.Location:
	return creep_location

func notify_player_inside() -> void:
	player_inside = true
	if state == State.Hunting:
		creep_location = _find_closest_creep_spot()
		state = State.Creeping
		

func _start_chase() -> void:
	print("Chasing player!")
	state = State.Hunting
	target_location = player_target.global_position

func _on_outside_blood_lust_timer_timeout() -> void:
	if !player_inside:
		_start_chase()
