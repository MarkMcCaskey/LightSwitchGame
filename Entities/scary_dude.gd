class_name ScaryDude extends CharacterBody3D

signal ScaryDudeSafetyLevelChanged(old: int, new: int)

enum State { Hunting, Creeping, Idle, InHouse, EnteringHouse, MovingBetweenCreepSpots, BackingAway }

@export var state: State = State.Creeping:
	get: return state
	set(val):
		print(State.keys()[state] + " -> " + State.keys()[val])
		update_animation(state, val)
		if val == State.Hunting || val == State.InHouse || State.MovingBetweenCreepSpots || State.EnteringHouse:
			if pathfinding_fix_timer:
				position_at_last_timeout = global_position
				pathfinding_fix_timer.start(path_finding_check_time)
		state = val
		update_vars()

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
@onready var creature_final: CreatureW2Final = $creature_w2_final
@onready var monster_vision: Camera3D = $BoneAttachment3D/MonsterVision
@onready var creep_timer: Timer = $CreepTimer
@onready var pathfinding_fix_timer: Timer = $PathFindingFixTimer
@onready var outside_bloodlust_timer: Timer = $OutsideBloodLustTimer
@onready var extreme_danger_warning_timer: Timer = $ExtremeDangerWarningTimer
@onready var instant_kill_timer: Timer = $InstantKillTimer
@onready var instant_kill_timer_fail_safe: Timer = $InstantKillTimerFailSafe
const path_finding_check_time: float = 2.0
@onready var movement_audio: AudioStreamPlayer3D = $MovementAudio
@onready var passive_audio: AudioStreamPlayer3D = $PassiveAudio
@onready var sfx_audio: AudioStreamPlayer3D = $SfxAudio
@onready var major_event_audio: AudioStreamPlayer3D = $MajorEventAudio
@onready var rotate_ref: Node3D = $RotateRef
@onready var shoo_away_box: Area3D = $ShooAwayBox
@onready var shoo_away_box_collider: CollisionShape3D = $ShooAwayBox/CollisionShape3D

@onready var monster_aggression: float = base_monster_aggression
@onready var move_chance: int = base_move_chance
@onready var is_seen_by_player: bool = false

@onready var direction: Vector3 = Vector3(0,0,0)
@onready var creep_location: MonsterCreepSpot.Location = MonsterCreepSpot.Location.ColDeSacFar: #MonsterCreepSpot.Location.BedRoom1Window: #MonsterCreepSpot.Location.ColDeSacMiddle:
	get: return creep_location
	set(v):
		creep_location = v
		update_vars()
@onready var current_level: int = 0
@onready var current_xp: float = 0
@onready var xp_to_next_level: float = 5
@onready var is_in_the_house: bool = false
@onready var player_inside: bool = true

@onready var position_at_last_timeout: Vector3 = global_position
enum WarningType { Glass, WoodDoor }
@onready var warning_type: WarningType

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

const window_knocking_sfx: Array[AudioStream] = [
	preload("res://Assets/Audio/knocking-on-window-01.ogg"),
	preload("res://Assets/Audio/knocking-on-window-02.ogg"),
	preload("res://Assets/Audio/knocking-on-window-03.ogg"),
]
var last_window_knock_sfx_idx: int = -1

const door_knocking: AudioStream = preload("res://Assets/Audio/knocking.ogg")
const shoo_away_sound: AudioStream = preload("res://Assets/Audio/Dieing Beast.ogg")

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
	update_vars()

var tween: Tween
func _monster_look_at_player() -> void:
	if player_target: 
#		if tween: tween.kill()
#		rotate_ref.rotation_degrees = rotation_degrees
#		rotate_ref.look_at(player_target.global_position + Vector3(0, 0, 0), Vector3.UP)
#		tween = get_tree().create_tween()
#		rotate_ref.rotation.x = rotation.x
#		tween.tween_property(self, "rotation_degrees", rotate_ref.rotation_degrees + Vector3(0, -90, 0), 0.15).set_trans(Tween.TRANS_LINEAR)
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
			_nav_physics_process(delta, false)
		State.Creeping:
			_monster_look_at_player()
			_creep_physics_process(delta)
			move_and_slide()
		State.InHouse:
			_monster_look_at_player()
			if player_target:
				target_location = player_target.global_position
			_nav_physics_process(delta, false)
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
			var old_x := rotation.x
			look_at(next_path_position, Vector3.UP)
			rotation.x = old_x

		var new_velocity: Vector3 = next_path_position - current_agent_position
		#print("Next position = " + str(next_path_position) + "; " + str(new_velocity))
		direction = new_velocity.normalized()
	else:
		direction = Vector3(0., 0., 0.)
		if state == State.MovingBetweenCreepSpots:
			state = State.Creeping
			creep_timer.start()
		#animated_creature.breakdance()
	
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

func update_animation(old_state: State, new_state: State) -> void:
	if old_state == new_state: return
	# enum State { Hunting, Creeping, Idle, InHouse, EnteringHouse, MovingBetweenCreepSpots }
	match new_state:
		State.Creeping:
			creature_final.idle()
		State.Idle:
			creature_final.idle()
		State.Hunting:
			creature_final.run()
		State.MovingBetweenCreepSpots:
			creature_final.walk()
		State.EnteringHouse:
			creature_final.walk()
		State.BackingAway:
			creature_final.walk_back()

func update_vars() -> void:
	var shoo_away_enabled: bool = state == State.Creeping
	
	match creep_location:
		MonsterCreepSpot.Location.BedRoom1Window: pass
		MonsterCreepSpot.Location.BedRoom2Window: pass
		MonsterCreepSpot.Location.BackPorch: pass
		MonsterCreepSpot.Location.FrontDoor: pass
		MonsterCreepSpot.Location.BackGarageDoor: pass
		_: shoo_away_enabled = false
	
	if shoo_away_box && shoo_away_box_collider:
		if shoo_away_enabled:
			shoo_away_box.set_deferred("monitorable", true)
			shoo_away_box.set_deferred("monitoring", true)
			shoo_away_box_collider.disabled = false
		else:
			shoo_away_box.set_deferred("monitorable", false)
			shoo_away_box.set_deferred("monitoring", false)
			shoo_away_box_collider.disabled = true

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
	return randi_range(0, len(level_up_sfx) - 1)

func _get_new_rand_level_up_sfx_idx() -> int:
	var candidate: int = _get_rand_level_up_sfx_idx()
	while candidate == last_level_up_sfx_idx:
		candidate = _get_rand_level_up_sfx_idx()
	return candidate

func _get_rand_aggressive_sfx_idx() -> int:
	return randi_range(0, len(aggressive_idle_sfx) - 1)

func _get_new_rand_aggressive_sfx_idx() -> int:
	var candidate: int = _get_rand_aggressive_sfx_idx()
	while candidate == last_agressive_idle_sfx_idx:
		candidate = _get_rand_aggressive_sfx_idx()
	return candidate
	
func _get_rand_less_aggressive_sfx_idx() -> int:
	return randi_range(0, len(less_aggressive_idle_sfx) - 1)

func _get_new_rand_less_aggressive_sfx_idx() -> int:
	var candidate: int = _get_rand_less_aggressive_sfx_idx()
	while candidate == last_less_agressive_idle_sfx_idx:
		candidate = _get_rand_less_aggressive_sfx_idx()
	return candidate

func _get_rand_window_sfx_idx() -> int:
	return randi_range(0, len(window_knocking_sfx) - 1)

func _get_new_rand_window_sfx_idx() -> int:
	var candidate: int = _get_rand_window_sfx_idx()
	while candidate == last_window_knock_sfx_idx:
		candidate = _get_rand_window_sfx_idx()
	return candidate

func _update_location_to_creep_spot(smooth: bool) -> void:
	var creep_node = get_tree().get_first_node_in_group(MonsterCreepSpot.get_group_name(creep_location))
	assert(creep_node is MonsterCreepSpot, "at " + MonsterCreepSpot.Location.keys()[creep_location])
	if smooth:
		var tween := get_tree().create_tween()
		var distance := global_position.distance_to(creep_node.global_position)
		var time_to_arrive := distance / speed
		tween.tween_property(self, "global_position", creep_node.global_position, time_to_arrive).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "rotation", creep_node.rotation, time_to_arrive).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(_set_state_to_creeping)
	else:
		global_position = creep_node.global_position
		rotation = creep_node.rotation
		state = State.Creeping

func _set_state_to_creeping() -> void:
	state = State.Creeping
	creep_timer.start()

func _go_to_next_creep_spot() -> void:
	var next: MonsterCreepSpot.Location = MonsterCreepSpot.get_next_location_random(creep_location)
	_go_to_creep_spot(next)

func _go_to_creep_spot(next: MonsterCreepSpot.Location) -> void:
	var creep_node = get_tree().get_first_node_in_group(MonsterCreepSpot.get_group_name(creep_location))
	var current = creep_location
	if next == current:
		return
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
	
	if MonsterCreepSpot.is_by_door(next):
		warning_type = WarningType.WoodDoor
		extreme_danger_warning_timer.start(randf_range(0.4, 2.5))
	elif MonsterCreepSpot.is_by_glass(next):
		warning_type = WarningType.Glass
		extreme_danger_warning_timer.start(randf_range(0.4, 2.5))
	
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
	position_at_last_timeout = global_position
	target_location = player_target.global_position
	pathfinding_fix_timer.start()

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
	state = State.BackingAway
	var next: MonsterCreepSpot.Location
	if MonsterCreepSpot.is_on_roof(creep_location):
		next = MonsterCreepSpot.Location.RoofCenter
	else:
		next = MonsterCreepSpot.Location.DriveWayFar
	_go_to_creep_spot(next)
	sfx_audio.stream = shoo_away_sound
	sfx_audio.max_db = -10
	sfx_audio.play()
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
	print("PATH FINDER TIMED OUT!")
	if !(state == State.Hunting || state == State.InHouse || state == State.MovingBetweenCreepSpots || state == State.EnteringHouse):
		return
	pathfinding_fix_timer.start(path_finding_check_time)
	if navigation_agent.is_navigation_finished():
		if state == State.InHouse:
			target_location = player_target.global_position
		else:
			position_at_last_timeout = global_position
			return
	if _positions_approx_equal():
		if state == State.Hunting:
			print("Stuck hunting! teleport to creep spot?")
		elif state == State.InHouse:
			print("Stuck in house, teleport behind player? This should be its own mode")
			instant_kill_timer.start(randf_range(2.5, 39.6) / monster_aggression)
		elif state == State.MovingBetweenCreepSpots:
			_update_location_to_creep_spot(false)
			print("Stuck moving between creep spots!")
		elif state == State.EnteringHouse:
			print("Stuck entering house!")
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
	outside_bloodlust_timer.start(randf_range(1.3, 11.9) / factor)

func _find_closest_creep_spot() -> MonsterCreepSpot.Location:
	var closest_dist: float = 9999999
	var closest_loc: MonsterCreepSpot.Location
	for node in get_tree().get_nodes_in_group("creep_spots"):
		if node is MonsterCreepSpot:
			var dist = global_position.distance_to(node.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_loc = node.location
	return closest_loc

func notify_player_inside() -> void:
	player_inside = true
	if state == State.Hunting:
		creep_location  = _find_closest_creep_spot()
		var creep_node = get_tree().get_first_node_in_group(MonsterCreepSpot.get_group_name(creep_location))
		# hack because we should only be chasing on the ground, not on the roof
		if MonsterCreepSpot.is_on_same_level(MonsterCreepSpot.Location.FrontDoor, creep_location):
			state = State.MovingBetweenCreepSpots
			target_location = creep_node.global_position
		else:
			state = State.Creeping
			_update_location_to_creep_spot(true)
		

func _start_chase() -> void:
	print("Chasing player!")
	state = State.Hunting
	target_location = player_target.global_position

func _on_outside_blood_lust_timer_timeout() -> void:
	if !player_inside:
		_start_chase()

func _on_extreme_danger_warning_timer_timeout() -> void:
	match warning_type:
		WarningType.Glass:
			sfx_audio.volume_db = -15
			var idx: int = _get_new_rand_window_sfx_idx()
			last_window_knock_sfx_idx = idx
			sfx_audio.stream = window_knocking_sfx[idx]
			sfx_audio.play()
		WarningType.WoodDoor:
			sfx_audio.volume_db = -10
			sfx_audio.stream = door_knocking
			sfx_audio.play()
		_: assert(false, "unknown warning type " + WarningType.keys()[warning_type])

func _on_instant_kill_timer_timeout() -> void:
	global_position = player_target.global_position + Vector3(-1, 0, 0)
	_monster_look_at_player()
	instant_kill_timer_fail_safe.start()

func _on_instant_kill_timer_fail_safe_timeout() -> void:
	# and for good measure, let's not even rely on the hitbox
	player_target.kill_by(self)
