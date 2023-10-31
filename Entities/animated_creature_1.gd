class_name AnimatedCreature1 extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree

var playback: AnimationNodeStateMachinePlayback
var standing: bool = true

func _ready() -> void:
	animation_tree.active = true
	playback = animation_tree["parameters/playback"]
	playback.travel("DrunkWalk")

func crouch() -> void:
	if !standing:
		return
	standing = false
	playback.travel("StandToCrouch")

func breakdance() -> void:
	if standing:
		return
	playback.travel("BreakdanceFlair")

func stand_up() -> void:
	if standing:
		return
	standing = true
	playback.travel("CrouchToStand")
