extends Spatial

class_name Character

export (bool) var is_player_controlled = true
export (int) var action_points = 5

onready var global_state = get_node("/root/GlobalState")

var player_index = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	player_index = global_state.add_character(self)

func _process(delta):
	if player_index == 0:
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
