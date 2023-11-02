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
		#if mouse_on_task:
		#	event.position -= get_global_transform().origin
		print(event.global_position)
		print(sudoku.make_input_local(event).global_position)
		#print(subviewport.get_mouse_position())
		#event.position = subviewport.get_mouse_position()
		#subviewport.push_input(event.xformed_by(subviewport.get_screen_transform().affine_inverse()), false)
		#subviewport.push_input(sudoku.make_input_local(event))
		#subviewport.push_input(event.xformed_by(subviewport.get_global_transform().affine_inverse()), true)
		subviewport.push_input(event.xformed_by(sudoku.get_global_transform().affine_inverse()), false)
	else:
		subviewport.push_input(event)

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
