extends EnemyCharacter

onready var animation_player : AnimationPlayer = $Pivot/Dragon/AnimationPlayer

var is_alive = true
var is_hit = false

var directions : Array = [
	Vector2(1.0, 0.0),
	Vector2(1.0, -1.0),
	Vector2(0.0, -1.0),
	Vector2(-1.0, -1.0),
	Vector2(-1.0, 0.0),
	Vector2(-1.0, 1.0),
	Vector2(0.0, 1.0),
	Vector2(1.0, 1.0)
]

#############################################################################
# Character control

func _get_closest(p_bodies : Array) -> PlayerCharacter:
	var closest : PlayerCharacter = p_bodies[0]
	var dist = (closest.global_transform.origin - global_transform.origin).length()
	
	for player_character in p_bodies:
		var new_dist = (player_character.global_transform.origin - global_transform.origin).length()
		if new_dist < dist:
			closest = player_character
			dist = new_dist
	
	return closest

func became_current_character():
	var in_range = $AttackDetection.get_overlapping_bodies()
	if !in_range.empty():
		# attack!!
		
		# not yet implemented so go to the next character
		GlobalState.next_character()
		
		return
	
	in_range = $MoveDetection.get_overlapping_bodies()
	if !in_range.empty():
		# move toward characters
		var closest : PlayerCharacter = _get_closest(in_range)
		
		# find our path to our closest "enemy"
		var path : Array= AstarMaze.do_astar(_in_cell, closest.get_in_cell(), 5, true)
		if !path.empty():
			# move one cell
			tween_move_character(global_transform.origin, path[0].global_transform.origin)
		
		return
	
	GlobalState.next_character()

func _on_Tween_tween_all_completed():
	GlobalState.next_character()

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("Dragon_Flying")

func _on_AnimationPlayer_animation_finished(anim_name):
	if is_alive:
		if is_hit:
			animation_player.play("Dragon_Hit")
			is_hit = false
		else:
			animation_player.play("Dragon_Flying")
