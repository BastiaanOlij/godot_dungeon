extends Spatial

onready var camera_root : Spatial = get_node("PlayerCharacters/Mage/CameraRig")

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalState.connect("next_character", self, "_set_character")
	pass # Replace with function body.

func _set_character(p_character : Character):
	if p_character.is_player_controlled:
		var current_parent = camera_root.get_parent()
		if current_parent != p_character:
			var current_pos : Vector3 = camera_root.global_transform.origin
			current_parent.remove_child(camera_root)
			p_character.add_child(camera_root)
			camera_root.move(current_pos)

func _on_Maze_finished_init_maze():
	GlobalState.start_level()
