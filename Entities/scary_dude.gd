class_name ScaryDude extends CharacterBody3D

enum State { Hunting, Creeping, Idle }

@export var state: State = State.Creeping

@export var speed: float = 1.
@export var move_chance: int = 15

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var animated_creature: AnimatedCreature1 = $AnimatedCreature1
@onready var monster_vision: Camera3D = $BoneAttachment3D/MonsterVision
@onready var creep_timer: Timer = $CreepTimer
@export var target_location: Vector3 = Vector3(0.,0.,0.):
	get:
		return target_location
	set(value):
		target_location = value
		if navigation_agent:
			navigation_agent.target_position = value

var direction: Vector3 = Vector3(0,0,0)
var player_target: Player
var creep_location: MonsterCreepSpot.Location = MonsterCreepSpot.Location.ColDeSacFar

func _ready():
	monster_vision.add_to_group("monster_vision")
	#animation_tree.active = true

	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	#if target_location == Vector3.ZERO:
		#target_location = collision_shape.global_transform.origin

	navigation_agent.velocity_computed.connect(_on_nav_velocity_computed)
	navigation_agent.max_speed = speed
	player_target = get_tree().get_nodes_in_group("Player")[0]
	if state == State.Creeping:
		_update_location_to_creep_spot()
		creep_timer.start()
	look_at(player_target.global_position)
	target_location = player_target.global_position

func _physics_process(delta: float) -> void:
	match state:
		State.Idle:
			pass
		State.Hunting:
			_nav_physics_process(delta)
		State.Creeping:
			_creep_physics_process(delta)
	#if velocity == Vector3.ZERO:
	#velocity = Vector3(1., 0., 1.)
	move_and_slide()
	#update_animation()
	#update_facing_direction()

func _nav_physics_process(_delta: float) -> void:
	if player_target:
		look_at(player_target.global_position)
		target_location = player_target.global_position
	if !navigation_agent.is_navigation_finished():
		var current_agent_position: Vector3 = collision_shape.global_transform.origin
		var next_path_position: Vector3 = navigation_agent.get_next_path_position()

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
		velocity = next_velocity
	velocity = next_velocity

func _creep_physics_process(_delta: float) -> void:
	pass

func _on_nav_velocity_computed(safe_velocity: Vector3) -> void:
	#print(str(velocity) + " -> " + str(safe_velocity) + "; ")
	velocity = safe_velocity * speed

func seen_by_player() -> void:
	speed = 0.5

func end_seen_by_player() -> void:
	animated_creature.crouch()
	speed = 10.0

func _update_location_to_creep_spot() -> void:
	var creep_node = get_tree().get_first_node_in_group(MonsterCreepSpot.get_group_name(creep_location))
	assert(creep_node is MonsterCreepSpot, "at " + MonsterCreepSpot.Location.keys()[creep_location])
	global_position = creep_node.global_position
	global_rotation = creep_node.global_rotation

func _go_to_next_creep_spot() -> void:
	var creep_node = get_tree().get_first_node_in_group(MonsterCreepSpot.get_group_name(creep_location))
	var current = creep_location
	var next: MonsterCreepSpot.Location = MonsterCreepSpot.get_next_location_random(creep_location)
	creep_location = next
	print("Going from " + MonsterCreepSpot.Location.keys()[current]  + " to " + MonsterCreepSpot.Location.keys()[next])
	_update_location_to_creep_spot()


func _on_creep_timer_timeout() -> void:
	var n: int = randi_range(1, 20)
	print("Timer! Rolled a " + str(n))
	if move_chance > n:
		_go_to_next_creep_spot()
	creep_timer.start()
