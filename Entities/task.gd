class_name Task extends Interactable

signal TaskComplete

const target_progress: int = 18
var progress: int = 0

@onready var light: OmniLight3D = $OmniLight3D
@onready var progress_bar: ProgressBar = $ProgressBar/SubViewport/CenterContainer/ProgressBar
#@onready var distraction_manager: DistractionManager = $DistractionManager
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
		_exit_task()
		return

	if event is InputEventMouse:
		var main_viewport_size: Vector2 = get_viewport().size
		var subviewport_size: Vector2 = subviewport.size
		
		# this is a certified "good enough" moment
		# this code is required as sacrifice to the monster in this game
		# here be dragons
		event.position += Vector2(-280, -100)
		event.position /= Vector2(522, 500)
		event.position *= subviewport_size
		subviewport.push_input(event, true)
	else:
		subviewport.push_input(event)

func _exit_task() -> void:
	var player: Player = get_tree().get_first_node_in_group("Player")
	player.capture_mouse()
	player.interact_label.show()
	interacting_with_task = false
	player.camera.make_current()
	subviewport.set_input_as_handled()
	player.has_control = true

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

#func _gen_distraction(difficulty: int) -> void:
#	distraction_manager.generate_distraction(difficulty)


func _on_mouse_entered() -> void:
	mouse_on_task = true

func _on_mouse_exited() -> void:
	mouse_on_task = false

func _on_sudoku_sudoku_complete() -> void:
	light.show()
	progress = target_progress
	_exit_task()
	emit_signal("TaskComplete")

func _on_sudoku_sudoku_quit() -> void:
	_exit_task()
