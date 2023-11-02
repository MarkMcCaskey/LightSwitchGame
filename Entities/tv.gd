@tool
class_name Tv extends Node3D

@export var tv_on: bool = false:
	get: return tv_on
	set(val):
		tv_on = val
		_tv_screen_logic()
enum TvType { Tv3, Tv4 }
@export var tv_type: TvType:
	get: 
		return tv_type
	set(val): 
		tv_type = val
		if tv_mesh:
			_reload_tv_mesh()

@onready var tv_mesh: MeshInstance3D = $MeshInstance3D
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

const tv_static: Material = preload("res://Materials/tv_static.tres")
const tv_off_black: Material = preload("res://Materials/tv_off_black.tres")

func _ready() -> void:
	_reload_tv_mesh()
	#animation_tree.active = true

func _reload_tv_mesh() -> void:
	match tv_type:
		TvType.Tv3:
			tv_mesh.mesh = load("res://Entities/Objects/Resources/tv_3.tres")
		TvType.Tv4:
			tv_mesh.mesh = load("res://Entities/Objects/Resources/tv_4.tres")
	var material_0 = preload("res://Entities/Objects/Resources/tv_texture0.tres")
	tv_mesh.set_surface_override_material(0, material_0)
	_tv_screen_logic()

func _tv_screen_logic() -> void:
	if tv_mesh:
		if tv_on:
			tv_mesh.set_surface_override_material(1, tv_static)
			if audio_player: audio_player.play()
		else:
			tv_mesh.set_surface_override_material(1, tv_off_black)
			if audio_player: audio_player.stop()


func _on_interactable_on_interact() -> void:
	tv_on = !tv_on
