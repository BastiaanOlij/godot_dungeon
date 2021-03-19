extends Spatial

class_name Character

signal action_points_changed(new_ap)

export (bool) var is_player_controlled = true
export (int) var action_points = 5
export (int) var health_points = 5

onready var tween_node : Tween = get_node("Tween")
var player_index : int = -1
var current_action_points : int = 0

#############################################################################
# Character status

# while moving we could be in multiple cells but we should end up in one only.
var _in_cells : Array = Array()
var _in_cell : Cell = null

func cell_entered(p_cell : Cell):
	# if its not in here, we add it
	if !_in_cells.has(p_cell):
		_in_cells.push_back(p_cell)
	
	# we are now in this cell
	_in_cell = p_cell
	
	# print(name + " entered cell " + p_cell.name + " (" + str(_in_cells))

func cell_exited(p_cell : Cell):
	if _in_cells.has(p_cell):
		_in_cells.erase(p_cell)

		if _in_cells.empty():
			_in_cell = null
		else:
			_in_cell = _in_cells[0]

		# print(name + " exited cell " + p_cell.name + ", now in " + str(_in_cells))

func get_current_action_points() -> int:
	return current_action_points

#############################################################################
# Character control

func became_current_character():
	pass

func unset_current_character():
	pass

func pointer_cell_entered(p_cell : Cell):
	pass

func perform_action():
	pass

#############################################################################

# Called when the node enters the scene tree for the first time.
func _ready():
	player_index = GlobalState.add_character(self)
