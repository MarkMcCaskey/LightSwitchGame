class_name SlidingGlassDoorPiece extends Node3D

@export var is_open: bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if is_open:
		animation_player.play("Open")
	else:
		animation_player.play("Closed")

func _on_interactable_on_interact() -> void:
	is_open = !is_open
	if is_open:
		animation_player.play("ClosedToOpen")
	else:
		animation_player.play("OpenToClosed")
