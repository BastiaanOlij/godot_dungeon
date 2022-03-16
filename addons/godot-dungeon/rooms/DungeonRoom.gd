extends Spatial

class_name DungeonRoom

signal character_entered_room

export (int, FLAGS, "Left", "Top", "Right", "Bottom") var open_sides = 0
export (int) var weight = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$Helpers.visible = false

func _on_PlayerDetector_body_entered(body):
	# print("Hello " + body.name)
	emit_signal("character_entered_room", self)

func get_neighbouring_cells(p_cell : Cell) -> Array:
	var cells : Array = Array()
	var cell_pos = p_cell.global_transform.origin - global_transform.origin
	
	for cell in $Grid.get_children():
		if cell != p_cell:
			var delta = cell.transform.origin - cell_pos
			if abs(delta.x) <= 2.0 and abs(delta.z) <= 2.0:
				# print("Adding " + cell.name + " " + str(delta))
				cells.push_back(cell)
	
	# again bit dirty but we can make this assumption
	var maze = get_parent()
	if maze.has_method("get_neighbouring_room"):
		if cell_pos.x == -5.0:
			var room = maze.get_neighbouring_room(self, Vector2(-1.0, 0.0))
			if room:
				cells.append_array(room.get_neighbouring_cells(p_cell))

		if cell_pos.x == 5.0:
			var room = maze.get_neighbouring_room(self, Vector2(1.0, 0.0))
			if room:
				cells.append_array(room.get_neighbouring_cells(p_cell))

		if cell_pos.z == -5.0:
			var room = maze.get_neighbouring_room(self, Vector2(0.0, -1.0))
			if room:
				cells.append_array(room.get_neighbouring_cells(p_cell))

		if cell_pos.z == 5.0:
			var room = maze.get_neighbouring_room(self, Vector2(0.0, 1.0))
			if room:
				cells.append_array(room.get_neighbouring_cells(p_cell))

	return cells
