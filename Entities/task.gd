class_name Task extends Interactable

const target_progress: int = 18
var progress: int = 0

@onready var light: OmniLight3D = $OmniLight3D
@onready var progress_bar: ProgressBar = $Sprite3D/SubViewport/CenterContainer/ProgressBar
@onready var distraction_manager: DistractionManager = $DistractionManager
@onready var last_update: int = 0

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

func interact() -> void:
	if progress >= target_progress:
		return
	progress += 1
	if (progress - last_update) >= 2:
		#call_deferred("_gen_distraction", 1)
		last_update = progress
		_gen_distraction(1)
	progress_bar.value = progress
	if progress >= target_progress:
		light.show()

func _gen_distraction(difficulty: int) -> void:
	distraction_manager.generate_distraction(difficulty)
