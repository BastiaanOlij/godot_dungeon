extends Area

signal ray_enter
signal ray_exit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_ray_enter():
	emit_signal("ray_enter")

func on_ray_exit():
	emit_signal("ray_exit")
