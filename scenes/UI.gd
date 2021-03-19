extends CanvasLayer

var current_character : Character = null

func _set_turn(p_new_turn : int):
	$TurnState/Turn.text = "Turn: "+ str(p_new_turn)

func _action_points_changed(p_new_ap : int):
	$Player/AP.text = "AP: " + str(p_new_ap)

func _next_character(p_new_character : Character):
	if current_character == p_new_character:
		return

	if current_character:
		current_character.disconnect("action_points_changed", self, "_action_points_changed")
	
	current_character = p_new_character
	if current_character:
		current_character.connect("action_points_changed", self, "_action_points_changed")
		$Player.visible = current_character.is_player_controlled
		_action_points_changed(current_character.get_current_action_points())

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalState.connect("next_turn", self, "_set_turn")
	GlobalState.connect("next_character", self, "_next_character")
	_next_character(GlobalState.get_current_character())

func _on_Button_pressed():
	GlobalState.next_character()
