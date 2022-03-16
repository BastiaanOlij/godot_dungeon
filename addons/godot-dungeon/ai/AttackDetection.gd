tool
extends AIAction

export var radius = 4.0 setget set_radius
export var attack_cost = 2
export var spawn_point : NodePath
export var attack_scene : PackedScene

onready var spawn_point_node : Spatial = get_node_or_null(spawn_point)

func set_radius(new_value):
	radius = new_value
	if is_inside_tree():
		_update_radius()

func process_action(p_character : Character):
	if !spawn_point_node:
		print("No spawn point")
		return

	if !attack_scene:
		print("No attack scene")
		return

	# If we don't have enough action points left to attack, we don't check.
	if p_character.current_action_points < attack_cost:
		print("Not enough action points")
		return
	
	var in_range = $Area.get_overlapping_bodies()
	if !in_range.empty():
		# attack!!
		print("Attach ", in_range[0].name)

		# decrease action points
		p_character.current_action_points = p_character.current_action_points - attack_cost
		emit_signal("action_points_changed", p_character.current_action_points)

		var attack_node = attack_scene.instance()
		add_child(attack_node)
		attack_node.connect("attack_finished", self, "_attack_finished")
		attack_node.perform_attack(in_range[0], spawn_point_node.global_transform)
	
	return

func _attack_finished():
	emit_signal("do_next_move")

func _ready():
	_update_radius()

func _update_radius():
	var sphere : SphereShape = $Area/CollisionShape.shape
	sphere.radius = radius
