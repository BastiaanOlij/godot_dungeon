extends Node

var characters = Array()
var current_character = 0
var turn = 1

func reset_level():
	characters = Array()
	current_character = 0
	turn = 1

func add_character(p_node : KinematicBody) -> int:
	characters.push_back(p_node)

	print(characters)

	return characters.size() - 1 

func get_positions(p_include_player : bool, p_include_enemy : bool) -> Array:
	var arr : Array = Array()
	
	for character in characters:
		if character.is_player_controlled && p_include_player:
			arr.push_back(character.global_transform.origin)
		elif !character.is_player_controlled && p_include_enemy:
			arr.push_back(character.global_transform.origin)
	
	return arr 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


