class_name Door extends Interactable

@export var closed: bool = true:
	get: return closed
	set(val):
		closed = val
		if closed:
			t = 0
			dt = -1
		else:
			t = 1
			dt = 1
@onready var animation_tree: AnimationTree = $AnimationTree

var t: float = 0 # 0 = closed, 1 = opened
var dt: float = -1 # -1 = closing, +1 = opening

func _ready() -> void:
	animation_tree.active = true

func _process(delta):
	t += delta * dt
	t = clampf(t, 0., 1.)
	animation_tree["parameters/Open/blend_position"] = t

func interact() -> void:
	dt = -dt
