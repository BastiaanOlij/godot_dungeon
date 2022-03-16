extends Spatial

class_name AIAction

signal do_next_move

func _get_closest(p_bodies : Array) -> PlayerCharacter:
	var closest : PlayerCharacter = p_bodies[0]
	var dist = (closest.global_transform.origin - global_transform.origin).length()
	
	for player_character in p_bodies:
		var new_dist = (player_character.global_transform.origin - global_transform.origin).length()
		if new_dist < dist:
			closest = player_character
			dist = new_dist
	
	return closest

func process_action(p_character : Character):
	return

