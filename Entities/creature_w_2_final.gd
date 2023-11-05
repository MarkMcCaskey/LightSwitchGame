class_name CreatureW2Final extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer

func run() -> void:
	anim.play("DrunkRun")

func walk() -> void:
	anim.play("DrunkWalk")

func walk_back() -> void:
	anim.play("RunBackwards")

func twerk() -> void:
	anim.play("Twerk")

func idle() -> void:
	var i := randi_range(1, 2)
	if i == 1:
		anim.play("Idle1")
	else:
		anim.play("Idle2")
