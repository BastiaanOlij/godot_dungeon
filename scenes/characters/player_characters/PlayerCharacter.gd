extends Character

class_name PlayerCharacter

var current_move_path : Array = Array()
var moving = false;
const move_speed = 0.25

var ap = 0

func became_current_character():
	# reset our turn points
	ap = action_points

func turn_state_changed(p_state : int):
	match p_state:
		GlobalState.TurnState.TURN_MOVE:
			_do_a_star(_in_cell, GlobalState.get_current_cell())

func pointer_cell_entered(p_cell : Cell):
	match GlobalState.get_turn_state():
		GlobalState.TurnState.TURN_MOVE:
			_do_a_star(_in_cell, p_cell)

func _move_character(new_pos : Vector3):
	global_transform.origin = new_pos

func _rotate_character(new_rotation : float):
	$Pivot.rotation.y = new_rotation

func perform_action():
	match GlobalState.get_turn_state():
		GlobalState.TurnState.TURN_MOVE:
			moving = true
			print("Start move")
			animation_player.play("Walk")

			while !current_move_path.empty() and ap > 0:
				var next_cell : Cell = current_move_path.pop_front()
				ap = ap - 1

				# determine our move
				var move_from = global_transform.origin
				var move_to = next_cell.global_transform.origin
				var delta_move = (move_to - move_from)
				var distance = delta_move.length()
				tween_node.interpolate_method(self, "_move_character", move_from, move_to, distance * move_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

				var angle_from = $Pivot.rotation.y
				var angle_to = Vector2(delta_move.x, delta_move.z).angle_to(Vector2(0, 1))
				tween_node.interpolate_method(self, "_rotate_character", angle_from, angle_to, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

				# start our tween
				tween_node.start()

				# wait for our tween to finish
				yield(tween_node, "tween_all_completed")
			
			print("Finished move")

			moving = false
			if ap == 0:
				GlobalState.next_turn_state()
			else:
				# init our next move
				_do_a_star(_in_cell, GlobalState.get_current_cell())

func _do_a_star(from_cell: Cell, to_cell : Cell):
	if moving:
		# already processing our move, don't do this
		print("Busy moving....")
		return
	
	if from_cell and to_cell:
		current_move_path = AstarMaze.do_astar(from_cell, to_cell, ap)
	
		if !current_move_path.empty():
			to_cell.set_cell_status(Cell.CellStatus.CELL_STATUS_CAN_MOVE)
			
			# print(current_move_path)
			for cell in current_move_path:
				cell.mark()
		else:
			to_cell.set_cell_status(Cell.CellStatus.CELL_STATUS_CANT_MOVE)

func _on_AnimationPlayer_animation_finished(anim_name):
	if moving and anim_name == "Walk":
		animation_player.play("Walk")
