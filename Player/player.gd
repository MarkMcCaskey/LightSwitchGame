class_name Player extends CharacterBody3D

@export_category("Player")
@export_range(1, 35, 1) var speed: float = 10 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

@export var has_control: bool = true

var jumping: bool = false
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

@onready var camera: Camera3D = $Camera
@onready var interact_ray: RayCast3D = $Camera/InteractRayCast
@onready var interact_label: Label = $Camera/CenterContainer/InteractLabel
@onready var monster_visible_ray: RayCast3D = $Camera/LookingAtMonsterRay

var current_interactable: Interactable
var last_seen_monster: ScaryDude

func _ready() -> void:
	interact_label.hide()
	capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if !has_control: return
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed("jump"): jumping = true
	if Input.is_action_just_pressed("exit"): get_tree().quit()
	if Input.is_action_just_pressed("interact") && current_interactable: current_interactable.interact()
	if Input.is_action_just_pressed("debug_spawn_distractions"):
		play_death_scene()
#		for room in Room.RoomName.values():
#			if room == Room.RoomName.None: continue
#			var spawn_group = Room.room_name_to_spawn_group(room)
#			for spawner in get_tree().get_nodes_in_group(spawn_group):
#				spawner.spawn_object()

func _physics_process(delta: float) -> void:
	# HACK: this also disables physics which isn't necessarily clear by the name `has_control`
	if !has_control:
		return
	#print(Engine.get_frames_per_second())
	if mouse_captured: _handle_joypad_camera_rotation(delta)
	velocity = _walk(delta) + _gravity(delta) + _jump(delta)
	var c = interact_ray.get_collider()
	if c && c is Interactable:
		if c != current_interactable:
			interact_label.text = "Press E to " + c.interact_text
			interact_label.show()
			current_interactable = c
	else:
		interact_label.hide()
		current_interactable = null
	
	# using a ray here is a bit of a hack, we want either a vision cone or like
	# multiple rays that follow the camera FoV
	var mc = monster_visible_ray.get_collider()
	if mc && mc.name == "VisibleAura":
		if mc != last_seen_monster:
			var monster: ScaryDude = mc.get_parent()
			last_seen_monster = monster
			monster.seen_by_player()
	else:
		if last_seen_monster && is_instance_valid(last_seen_monster):
			last_seen_monster.end_seen_by_player()
		last_seen_monster = null
	move_and_slide()

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(sens_mod: float = 1.0) -> void:
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector("look_left","look_right","look_up","look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		look_dir = Vector2.ZERO

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

func play_death_scene() -> void:
	var death_scene = load("res://Entities/DeathScene.tscn").instantiate()
	add_child(death_scene)
	death_scene.camera.make_current()
