extends Spatial

class_name Character

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	# this needs to be COMPLETELY different
	var direction = Vector3()
	
	if Input.is_action_pressed("ui_left"):
		direction = Vector3(-1.0, 0.0, 0.0)
	elif Input.is_action_pressed("ui_right"):
		direction = Vector3(1.0, 0.0, 0.0)
	elif Input.is_action_pressed("ui_up"):
		direction = Vector3(0.0, 0.0, -1.0)
	elif Input.is_action_pressed("ui_down"):
		direction = Vector3(0.0, 0.0, 1.0)
	
	transform.origin += direction * delta * 10.0
