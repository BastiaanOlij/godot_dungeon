extends Character

class_name EnemyCharacter

export (int) var weight = 1

#############################################################################
# Character control

func became_current_character():
	current_action_points = action_points
	emit_signal("action_points_changed", current_action_points)
	
	_do_next_move()

func _on_Tween_tween_all_completed():
	_do_next_move()

func _do_next_move():
	if current_action_points == 0:
		GlobalState.next_character()
	else:
		$AIBrain.process_actions(self)

func unset_current_character():
	pass
