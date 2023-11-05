class_name Player extends CharacterBody3D

signal Dying
signal SeeingStatic
signal HouseStatusChanged(is_in_house: bool)

@export_category("Player")
@export_range(1, 35, 1) var speed: float = 4 # m/s
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
@onready var jump_scare_sting: AudioStreamPlayer = $JumpScareSting
@onready var pause_menu: PauseMenu = $Camera/PauseMenu
@onready var is_dying: bool = false

var current_interactable: Interactable
var last_seen_monster: ScaryDude

func _ready() -> void:
	interact_label.hide()
	pause_menu.hide()
	capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if !has_control: return
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed("jump"): jumping = true
	if Input.is_action_just_pressed("ui_cancel"):
		release_mouse()
		get_tree().paused = true
		pause_menu.show()
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

func hide_everything() -> void:
	camera.hide()
	interact_label.hide()
	hide()

var death_scene_location: Vector3 = Vector3(0,0,0)
func kill_by(node: Node3D) -> void:
	has_control = false
	jump_scare_sting.play()
	var dummy := Node3D.new()
	add_child(dummy)
	dummy.rotation = camera.rotation
	dummy.look_at(node.global_position + Vector3(0, 1, 0), Vector3.UP)
	death_scene_location = node.global_position
	var tween := get_tree().create_tween()
	print("Going from " + str(camera.rotation) + " to " + str(dummy.rotation))
	tween.tween_property(camera, "rotation", dummy.rotation, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(play_death_scene)
	tween.tween_property(jump_scare_sting, "volume_db", -30, 5.0).set_ease(Tween.EASE_IN)

func play_death_scene() -> void:
	if is_dying:
		return
	is_dying = true
	var death_scene = load("res://Entities/DeathScene.tscn").instantiate()
	has_control = false
	emit_signal("Dying")
	death_scene.connect("StaticTriggered", _static_triggered)
	add_child(death_scene)
	death_scene.global_position = death_scene_location
	var old_z: float = death_scene.rotation.z
	death_scene.look_at(global_position)
	death_scene.rotation.z = old_z
	death_scene.camera.make_current()

func _static_triggered() -> void:
	emit_signal("SeeingStatic")

func enter_house() -> void:
	emit_signal("HouseStatusChanged", true)

func exit_house() -> void:
	emit_signal("HouseStatusChanged", false)

func _on_pause_menu_pause_menu_closed() -> void:
	pause_menu.hide()
	get_tree().paused = false
	capture_mouse()

