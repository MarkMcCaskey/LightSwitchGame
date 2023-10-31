extends Node3D

@onready var door: MeshInstance3D = $Door
@export var interact_text: String = "Press E to Interact!"
var r0: Quaternion = Quaternion.from_euler(Vector3(0, 0, 0))
var r1: Quaternion = Quaternion.from_euler(Vector3(0, -90, 0))
var t: float = 0 # 0 = closed, 1 = opened
var dt: float = -1 # -1 = closing, +1 = opening

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta * dt
	t = clampf(t, 0., 1.)
	self.quaternion = r0.slerp(r1, t)
	pass

func interact():
	dt = -dt
	pass
