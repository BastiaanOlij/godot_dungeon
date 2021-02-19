extends Spatial

signal character_entered_room

export (int, FLAGS, "Left", "Top", "Right", "Bottom") var open_sides = 0
export (int) var weight = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	# our guide is just for development
	$Guide.visible = false

func _on_Area_body_entered(body):
	# print("Hello " + body.name)
	emit_signal("character_entered_room", self)
