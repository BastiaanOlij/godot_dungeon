extends Node

signal next_turn(turn_no)
signal next_character(character)
signal action_points_changed(action_points)

var game_started = false
var characters : Array = Array()
var current_character : int = -1
var turn : int = 1

var current_character_node : Character = null

##############################################################################
# Handling turns

func reset_level():
	game_started = false
	characters = Array()
	current_character = -1
	turn = 1

func start_level():
	game_started = true
	next_character()

func next_turn():
	turn = turn + 1
	# init our next turn.....
	
	emit_signal("next_turn", turn)

func get_current_character() -> Character:
	return current_character_node

func next_character():
	# let our current character know it's no longer the current character
	if current_character_node:
		current_character_node.unset_current_character()
	
	# check if we've gotten our characters yet
	if characters.size() == 0:
		return 
	
	current_character = current_character + 1
	if current_character == characters.size():
		current_character = 0
		next_turn()
	
	# let our character know it's now current
	current_character_node = characters[current_character]
	current_character_node.became_current_character()
	
	emit_signal("next_character", current_character_node)

##############################################################################
# handling input

var current_cell : Cell = null # the current cell our mouse is over

func get_current_cell() -> Cell:
	return current_cell

func cell_entered(p_cell: Cell):
	current_cell = p_cell
	if current_character_node:
		current_character_node.pointer_cell_entered(current_cell)

func cell_exited(p_cell: Cell):
	if current_cell == p_cell:
		current_cell = null

func _input(event):
	if event is InputEventMouseButton:
		if current_cell and event.button_index == 1 and event.pressed:
			current_character_node.perform_action()
			pass

##############################################################################
# Characters 

func add_character(p_node : Character) -> int:
	characters.push_back(p_node)

	if game_started and current_character == -1:
		next_character()

	return characters.size() - 1 

func remove_character(p_node : Character):
	# remove this character
	characters.erase(p_node)

	# TODO check if we have any player characters left, if not, game over...

func get_positions(p_include_player : bool, p_include_enemy : bool) -> Array:
	var arr : Array = Array()
	
	for character in characters:
		if character.is_player_controlled && p_include_player:
			arr.push_back(character.global_transform.origin)
		elif !character.is_player_controlled && p_include_enemy:
			arr.push_back(character.global_transform.origin)
	
	return arr 

##############################################################################

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


