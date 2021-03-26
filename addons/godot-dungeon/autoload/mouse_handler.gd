extends Node

var intersects_with = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseMotion:
		var camera : Camera = get_viewport().get_camera()
		var ray_origin : Vector3 = camera.project_ray_origin(event.position)
		var ray_dir : Vector3 = camera.project_ray_normal(event.position)
		var space : PhysicsDirectSpaceState  = get_viewport().world.direct_space_state
		
		var hit_test : Dictionary = space.intersect_ray(ray_origin, ray_origin + ray_dir * 50.0, [], 524288, true, true)
		if !hit_test.empty():
			if intersects_with != hit_test['collider']:
				if intersects_with:
					if intersects_with.has_method("on_ray_exit"):
						intersects_with.on_ray_exit()
				
				intersects_with = hit_test['collider']
				if intersects_with.has_method("on_ray_enter"):
					intersects_with.on_ray_enter()
			pass
		elif intersects_with:
			if intersects_with.has_method("on_ray_exit"):
				intersects_with.on_ray_exit()
			intersects_with = null
