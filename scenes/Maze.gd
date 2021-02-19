extends Spatial

signal open_sides_changed(new_sides)

export (Array, ShaderMaterial) var fog_of_war_materials = Array()
export (float) var fog_of_war_distance = 15.0
export (float) var fog_of_war_rim = 10.0

onready var global_state = get_node("/root/GlobalState")

var maze : Dictionary

var expand_sides : Array = [ 
	Vector2(-1, 0),
	Vector2(-1, -1),
	Vector2(0, -1),
	Vector2(1, -1),
	Vector2(1, 0),
	Vector2(1, 1),
	Vector2(0, 1), 
	Vector2(-1, 1), 
	Vector2(-2, 0),
	Vector2(0, -2),
	Vector2(2, 0),
	Vector2(0, 2),
]

var check_sides : Array = [ Vector2(-1, 0), Vector2(0, -1), Vector2(1, 0), Vector2(0, 1) ]
var rev_bits : Array = [ 4, 8, 1, 2 ]
var room_types : Array = Array()

var open_sides = 0
var max_distance = 40.0

func update_visibility():
	var positions = global_state.get_positions(true, false)
	for room in get_children():
		var is_visible = false
		var room_pos = room.global_transform.origin
		for position in positions:
			if (room_pos - position).length() < max_distance:
				is_visible = true

		if room.visible != is_visible:
			room.visible = is_visible

func character_entered_room(room):
	var pos : Vector2 = Vector2(round(room.transform.origin.x / 12.0), round(room.transform.origin.z / 12.0))
	
	for side in expand_sides:
		var side_pos = pos + side
		if !maze.has(side_pos):
			# Don't have an entry? create one
			
			# Need to check each side to see if we have a tile with a passage
			# We use a bitwise function here with the following definition:
			# - bit 0 : Left must be a passage
			# - bit 1 : Top must be a passage
			# - bit 2 : Right must be a passage
			# - bit 3 : Bottom must be a passage
			# - bit 4 : Left must be a wall
			# - bit 5 : Top must be a wall
			# - bit 6 : Right must be a wall
			# - bit 7 : Bottom must be a wall
			
			var needs = 0
			var idx = 0
			for check_side in check_sides:
				var check_pos = side_pos + check_side
				if maze.has(check_pos):
					var os = maze[check_pos]['open_sides']
					var ws = ~os
					
					if (os & rev_bits[idx]) != 0:
						# we need a passage
						needs = needs + int(pow(2, idx))
					
					if (ws & rev_bits[idx]) != 0:
						# we need a wall
						needs = needs + int(pow(2, idx + 4))
				
				idx = idx + 1
			
			# Need to filter room_types to find rooms that fit
			var rooms_that_fit : Array = Array()
			for room_type in room_types:
				var has = room_type['open_sides']
				has += ~has << 4
				if ((has & needs) == needs):
					for i in room_type['weight']:
						rooms_that_fit.push_back(room_type)
			
			# random pick one
			var index = randi() % rooms_that_fit.size()
			var new_room = rooms_that_fit[index]['roomscene'].instance()
			new_room.transform.origin = Vector3(side_pos.x * 12.0, 0.0, side_pos.y * 12.0)
			add_child(new_room)
			
			_add_entry(new_room)
	
	update_visibility();

func _add_entry(room):
	var entry : Dictionary = Dictionary()
	var pos : Vector2 = Vector2(round(room.transform.origin.x / 12.0), round(room.transform.origin.z / 12.0))
	entry['node'] = room
	entry['open_sides'] = room.open_sides
	
	maze[pos] = entry
	for i in check_sides.size():
		var bit = int(pow(2, i))
		if ((room.open_sides & bit) == bit):
			# check our adjoining tile
			var side_pos = pos + check_sides[i]
			if maze.has(side_pos):
				# we "closed" an opening
				open_sides = open_sides - 1
			else:
				# no time, a new opening was created
				open_sides = open_sides + 1
			emit_signal("open_sides_changed", open_sides)
	
	room.connect("character_entered_room", self, "character_entered_room")

func _ready():
	# load our room scenes
	var dir = Directory.new()
	if dir.open("res://scenes/rooms") == OK:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != '':
			if dir.current_is_dir():
				pass
			elif !filename.ends_with('.tscn'):
				pass
			elif filename != 'Room.tscn':
				var entry : Dictionary = Dictionary()
				var room = load("res://scenes/rooms/" + filename)
				entry['roomscene'] = room
				# need to find a less wasteful way of doing this..
				var temp = room.instance()
				entry['open_sides'] = temp.open_sides
				entry['weight'] = temp.weight
				
				room_types.push_back(entry)
			
			filename = dir.get_next()
	
	# lets check out existing tiles
	for child in get_children():
		_add_entry(child)

func _process(delta):
	var positions = global_state.get_positions(true, false)
	for mat in fog_of_war_materials:
		mat.set_shader_param("max_distance", fog_of_war_distance)
		mat.set_shader_param("rim_size", fog_of_war_rim)
		for i in 4:
			if i < positions.size():
				mat.set_shader_param("player_"+str(i+1), positions[i])
			else:
				mat.set_shader_param("player_"+str(i+1), positions[0])
