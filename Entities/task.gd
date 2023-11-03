class_name Task extends Interactable

const target_progress: int = 18
var progress: int = 0

@onready var light: OmniLight3D = $OmniLight3D
@onready var progress_bar: ProgressBar = $ProgressBar/SubViewport/CenterContainer/ProgressBar
@onready var distraction_manager: DistractionManager = $DistractionManager
@onready var last_update: int = 0
@onready var camera: Camera3D = $Puzzle/Camera3D
@onready var subviewport: SubViewport = $Puzzle/SubViewport
@onready var sudoku: Sudoku = $Puzzle/SubViewport/Sudoku

@export var dbg_plane_normal_inverted: bool = false
@export var dbg_local_coords: bool = false
@export var dbg_sudoku_size: bool = false

var interacting_with_task: bool = false
var mouse_on_task: bool = false

func _process(delta: float) -> void:
	if progress >= target_progress:
		light.light_color.h += 1. * (delta / 3.)
		if light.light_color.h > 1.0:
			light.light_color.h -= 1.0

func _ready() -> void:
	progress = 0
	progress_bar.max_value = target_progress
	progress_bar.value = progress
	light.hide()
	# DEBUG:
	interacting_with_task = true

func _input(event: InputEvent) -> void:
	if !interacting_with_task: return
	if event.is_action_pressed("ui_cancel"):
		var player: Player = get_tree().get_first_node_in_group("Player")
		player.capture_mouse()
		player.interact_label.show()
		interacting_with_task = false
		player.camera.make_current()
		subviewport.set_input_as_handled()
		player.has_control = true
		return

	if event is InputEventMouse:
		var mouse_pos: Vector2 = event.position
		var from := camera.project_ray_origin(mouse_pos)
		var to := from + camera.project_ray_normal(mouse_pos) * 100
		print(camera.global_rotation_degrees)
		var plane_normal := Vector3(0, 0, 1)
		if dbg_plane_normal_inverted: plane_normal *= -1
		var plane_point := Vector3(0, 0, 0)
		
		# Vector3 or null
		var intersection = _get_ray_plane_intersection(from, to, plane_point, plane_normal)
		print("Ray from: " + str(from) + " to: " + str(to))
		
		if intersection:
			print("Intersection = " + str(intersection))
			var local_intersection_2d: Vector2 = _map_to_subviewport_2d(intersection)
			var main_viewport_size: Vector2 = get_viewport().size
			var subviewport_size: Vector2 = subviewport.size
			var scale_ratio: Vector2 = subviewport_size / main_viewport_size
			var invert_ratio: Vector2 = main_viewport_size / subviewport_size


			#local_intersection_2d += (subviewport_size * 0.5)
			local_intersection_2d *= invert_ratio
			print(event.position)
			print(local_intersection_2d)
			event.position = local_intersection_2d
			subviewport.push_input(event, dbg_local_coords)
	else:
		subviewport.push_input(event)

func _map_to_subviewport_2d(intersection_3d: Vector3) -> Vector2:
	var subviewport_rect: Rect2 = subviewport.get_visible_rect()
	var intersection_2d: Vector2 = Vector2(
		intersection_3d.x,
		-intersection_3d.y  # Inverting Y because 2D is Y-down while 3D is Y-up
	)
	# Normalize the intersection point to the range of [0, 1]
	intersection_2d += Vector2(1, 1)  # Translate to positive range
	#intersection_2d *= 0.5  # Scale down by half
	intersection_2d *= 0.5
	# Map to subviewport size and account for its position
	if dbg_sudoku_size:
		intersection_2d.x *= sudoku.size.x
		intersection_2d.y *= sudoku.size.y
		intersection_2d += sudoku.position
	else:
		intersection_2d.x *= subviewport_rect.size.x
		intersection_2d.y *= subviewport_rect.size.y
		print(subviewport_rect.position)
		#print(subviewport.position)
		#print(subviewport.global_position)
		#intersection_2d += subviewport_rect.position# + Vector2(-50, -165)
		intersection_2d += Vector2(-195, -100)
	return intersection_2d

#func _map_to_2d(intersection_3d: Vector3, viewport_size: Vector2) -> Vector2:
#	var intersection_2d: Vector2 = Vector2()
#	intersection_2d.x = intersection_3d.x + viewport_size.x * 0.5
#	intersection_2d.y = viewport_size.y * 0.5 - intersection_3d.y
#	return intersection_2d

func _get_ray_plane_intersection(from: Vector3, to: Vector3, plane_point: Vector3, plane_normal: Vector3):
	var dir: Vector3 = to - from
	var denom: float = plane_normal.dot(dir)
	if abs(denom) > 1e-6:
		var t: float = (plane_point - from).dot(plane_normal) / denom
		if t >= 0.0:
			return from + dir * t
	return null

func interact() -> void:
	var player: Player = get_tree().get_first_node_in_group("Player")
	player.has_control = false
	player.release_mouse()
	player.interact_label.hide()
	interacting_with_task = true
	camera.make_current()
#	if progress >= target_progress:
#		return
#	progress += 1
#	if (progress - last_update) >= 2:
#		#call_deferred("_gen_distraction", 1)
#		last_update = progress
#		_gen_distraction(1)
#	progress_bar.value = progress
#	if progress >= target_progress:
#		light.show()

func _gen_distraction(difficulty: int) -> void:
	distraction_manager.generate_distraction(difficulty)


func _on_mouse_entered() -> void:
	mouse_on_task = true

func _on_mouse_exited() -> void:
	mouse_on_task = false
