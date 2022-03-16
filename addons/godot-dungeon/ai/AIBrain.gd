extends Spatial

class_name AIBrain

signal do_next_move

func _ready():
	for action in get_children():
		action.connect("do_next_move", self, "_do_next_move")

func _do_next_move():
	# pass it down the chain
	emit_signal("do_next_move")

func process_actions(p_character : Character):
	for action in get_children():
		if action is AIAction:
			var was_points = p_character.current_action_points
			action.process_action(p_character)
			if p_character.current_action_points != was_points:
				print("New action points " + str(p_character.current_action_points))
				return
	
	GlobalState.next_character()
