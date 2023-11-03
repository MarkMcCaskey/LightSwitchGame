extends Node3D

@onready var cam: Camera3D = $Camera3D
@onready var mesh: MeshInstance3D = $CubeSpace/MeshInstance3D
@onready var l: Node3D = $CubeSpace

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var space_state = get_world_3d().direct_space_state
	
	var mp = get_viewport().get_mouse_position()
	var p0 = cam.project_ray_origin(mp)
	var p1 = p0 + cam.project_ray_normal(mp) * 4
	
	var query = PhysicsRayQueryParameters3D.create(p0, p1)
	query.collide_with_areas = true
	query.collision_mask = 1 << 3
	var result = space_state.intersect_ray(query)
	
	if result:
		print(" ")
		print(l.to_local(result.position))
		
		
	
	pass
