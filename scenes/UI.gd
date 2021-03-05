extends CanvasLayer

func _set_turn(p_turn : int):
	$Turn.text = "Turn: "+ str(p_turn)

func _set_state(p_state : int):
	match p_state:
		GlobalState.TurnState.TURN_MOVE:
			$State.text = "Move"
		_:
			$State.text = "Unknown"

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalState.connect("next_turn", self, "_set_turn")
	GlobalState.connect("next_state", self, "_set_state")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
