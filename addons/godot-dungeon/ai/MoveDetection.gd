tool
extends AIAction

export var radius = 8.0 setget set_radius
export var min_steps = 1

func set_radius(new_value):
	radius = new_value
	if is_inside_tree():
		_update_radius()

func process_action(p_character : Character):
	if p_character.current_action_points == 0:
		return
	
	var in_range = $Area.get_overlapping_bodies()
	if !in_range.empty():
		# move toward characters
		var closest : PlayerCharacter = _get_closest(in_range)
		
		# find our path to our closest "enemy"
		var path : Array = AstarMaze.do_astar(p_character.get_in_cell(), closest.get_in_cell(), 5, true)
		if !path.empty():
			if path.size() >= min_steps:
				# move one cell
				p_character.current_action_points = p_character.current_action_points - 1
				emit_signal("action_points_changed", p_character.current_action_points)
				p_character.tween_move_character(global_transform.origin, path[0].global_transform.origin)
			else:
				# TODO turn to face enemy
				pass
	return

func _ready():
	_update_radius()

func _update_radius():
	var sphere : SphereShape = $Area/CollisionShape.shape
	sphere.radius = radius
