class_name Task extends Interactable

const target_progress: int = 10
var progress: int = 0

@onready var light: OmniLight3D = $OmniLight3D
@onready var progress_bar: ProgressBar = $Sprite3D/SubViewport/CenterContainer/ProgressBar

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
	progress_bar.value = progress
	if progress >= target_progress:
		light.show()
