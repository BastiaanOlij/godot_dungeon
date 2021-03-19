extends Spatial

func _move_camera(p_to : Vector3):
	transform.origin = p_to

func move(p_from : Vector3):
	# make sure we have our starting position
	global_transform.origin = p_from
	$Tween.interpolate_method(self, "_move_camera", transform.origin, Vector3(), 1.0,Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
