extends Spatial

var maze : Dictionary

var sides : Array = [ Vector2(-1, 0), Vector2(0, -1), Vector2(1, 0), Vector2(0, 1) ]
var rev_bits : Array = [ 4, 8, 1, 2 ]
var room_types : Array = Array()

func character_entered_room(room):
	var pos : Vector2 = Vector2(round(room.transform.origin.x / 12.0), round(room.transform.origin.z / 12.0))
	
	for side in sides:
		var side_pos = pos + side
		if !maze.has(side_pos):
			# Don't have an entry? create one
			print("No room at " + str(side_pos))
			
			# Need to check each side to see if we have a tile with a passage
			var need_open_sides = 0
			var need_walls = 0
			var idx = 0
			for check_side in sides:
				var check_pos = side_pos + check_side
				if maze.has(check_pos):
					var os = maze[check_pos]['open_sides']
					var ws = ~os
					
					print("Checking " + str(idx) + " " + str(check_pos) + " " + str(maze[check_pos]['open_sides']))
					if (os & rev_bits[idx]) != 0:
						need_open_sides = need_open_sides + int(pow(2, idx))
					
					if (ws & rev_bits[idx]) != 0:
						need_walls = need_walls + int(pow(2, idx))
				
				idx = idx + 1
			
			# Need to filter room_types to find rooms that fit
			var rooms_that_fit : Array = Array()
			for room_type in room_types:
				var os = room_type['open_sides']
				var ws = ~os
				if ((os & need_open_sides) == need_open_sides) && ((ws & need_walls) == need_walls):
					rooms_that_fit.push_back(room_type)
			
			# random pick one
			var index = randi() % rooms_that_fit.size()
			var new_room = rooms_that_fit[index]['roomscene'].instance()
			new_room.transform.origin = Vector3(side_pos.x * 12.0, 0.0, side_pos.y * 12.0)
			add_child(new_room)
			
			print("Result: " + str(need_open_sides))
			
			_add_entry(new_room)

func _add_entry(room):
	var entry : Dictionary = Dictionary()
	var pos : Vector2 = Vector2(round(room.transform.origin.x / 12.0), round(room.transform.origin.z / 12.0))
	entry['node'] = room
	entry['open_sides'] = room.open_sides
	
	print("Add " + str(pos) + " - " + str(entry) + " to maze")
	
	maze[pos] = entry
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
				
				room_types.push_back(entry)
			
			filename = dir.get_next()
	
	# lets check out existing tiles
	for child in get_children():
		_add_entry(child)

