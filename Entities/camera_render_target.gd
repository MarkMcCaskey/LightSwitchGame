class_name CameraRenderTarget extends Node3D

@onready var sub_viewport: SubViewport = $Sprite3D/SubViewport

func _ready() -> void:
	call_deferred("setup")

func setup() -> void:
	await get_tree().physics_frame
	var monster_vision = get_tree().get_first_node_in_group("monster_vision")
	if monster_vision && monster_vision is Camera3D:
		# NOTE: this code doesn't work, deal with it later
		#var bone_attachment = monster_vision.get_parent()
		pass
		#var node_path = "/" + bone_attachment.get_path().get_concatenated_names()
		#node_path += "/" + bone_attachment.get_external_skeleton().get_concatenated_names()
		#bone_attachment.reparent(sub_viewport)
		#print(node_path)
		#var node_path = NodePath("/root/Main/ScaryDude/AnimatedCreature1/RootNode/Armature/Skeleton3D")
		#bone_attachment.set_external_skeleton(node_path)
		#print(str(bone_attachment))
		#monster_vision.current = true
		#sub_viewport.add_child(monster_vision)
		#monster_vision.
		#sub_viewport.ca
