extends Node

# Our own astar logic specific to our dungeon

##############################################################################
# Our A* logic

var open_list : Dictionary = Dictionary()
var close_list : Dictionary = Dictionary()

var debug_cell_list : Array = Array()

# Add a new cell to our open list
func _add_to_open_list(p_prev : Cell, p_next : Cell, p_end : Cell, p_current_cost : int, p_max_cost : int):
	var new_entry : Dictionary = Dictionary()
	new_entry['cell'] = p_next
	new_entry['prev'] = p_prev
	new_entry['g'] = p_current_cost
	
	var current_pos = p_next.global_transform.origin
	var end_pos = p_end.global_transform.origin
	var delta = end_pos - current_pos
	
	# g is real movement cost as an integer
	# h and f are floating point costs with a penalty for diagonal movement
	
	var x_cost = abs(delta.x / 2.0)
	var y_cost = abs(delta.z / 2.0)
	if p_current_cost + max(x_cost, y_cost) <= p_max_cost:
		if x_cost > y_cost:
			new_entry['h'] = x_cost + (y_cost * 0.5)
		else:
			new_entry['h'] = y_cost + (x_cost * 0.5)
		
		new_entry['f'] = float(new_entry['g']) + new_entry['h']
		open_list[p_next] = new_entry
		
		# print(p_next.full_name() + " - c: " + str(current_pos) + ", e: " + str(end_pos) + ", d: " + str(delta) + ", f: " + str(new_entry['f']))
		debug_cell_list.push_back(p_next)
		p_next.set_g("G: " + str(new_entry['g']))
		p_next.set_h("H: " + str(new_entry['h']))
		p_next.set_f("F: " + str(new_entry['f']))

# find the cell with our lowest cost
func _get_lowest_cost() -> Cell:
	var next = null
	
	for key in open_list:
		var cell = open_list[key]
		if next == null:
			next = cell
		elif next['f'] > cell['f']:
			next = cell
		elif next['f'] == cell['f'] and next['h'] < cell['h']:
			next = cell
	
	return next

# add more tries
func _add_tries(p_prev : Cell, p_to_cell : Cell, p_current_cost : int, p_max_cost : int, p_ignore_last_cell : bool):
	var neighbours = p_prev.get_neighbouring_cells()
	
	for cell in neighbours:
		if close_list.has(cell):
			# we've already processed this fully
			pass
		elif cell.is_occupied() and (!p_ignore_last_cell or cell != p_to_cell):
			# someone is already on this sell
			pass
		elif !open_list.has(cell):
			_add_to_open_list(p_prev, cell, p_to_cell, p_current_cost + 1, p_max_cost)
		elif open_list[cell]['g'] > p_current_cost + 1:
			# this one has become cheaper to reach!
			open_list[cell]['prev'] = p_prev
			open_list[cell]['g'] = p_current_cost + 1
			open_list[cell]['f'] = float(open_list[cell]['g']) + open_list[cell]['h']
			
			cell.set_g("*G: " + str(open_list[cell]['g']))
			cell.set_h("*H: " + str(open_list[cell]['h']))
			cell.set_f("*F: " + str(open_list[cell]['f']))

# return our final result
func _make_path_list(p_from_cell : Cell, p_to_cell : Cell, p_ignore_last_cell : bool) -> Array:
	var path_arr : Array = Array()
	var cell : Cell = p_to_cell
	
	while (cell != p_from_cell):
		if !p_ignore_last_cell or cell != p_to_cell:
			path_arr.push_front(cell)
		cell = close_list[cell]
	
	return path_arr

func do_astar(p_from_cell : Cell, p_to_cell : Cell, p_max_cost : int, p_ignore_last_cell : bool = false) -> Array:
	var empty_arr : Array = Array()
	
	for cell in debug_cell_list:
		cell.clear_debug()
	debug_cell_list = Array()
	
	# if our destination cell is not reachable, no need to do anything
	if p_to_cell.is_occupied() && !p_ignore_last_cell:
		return empty_arr
	elif p_from_cell == p_to_cell:
		return empty_arr
	
	# reset just in case
	open_list = Dictionary()
	close_list = Dictionary()
	
	# print("Find path from " + p_from_cell.full_name() + " to " + p_to_cell.full_name())
	
	_add_to_open_list(p_from_cell, p_from_cell, p_to_cell, 0.0, p_max_cost);
	while !open_list.empty():
		var next = _get_lowest_cost()
		
		# print("Lowest cost = " + next['cell'].full_name())
		
		# we are about to process this cell, add it to our close list
		close_list[next['cell']] = next['prev']
		
		# are we finished?
		if next['cell'] == p_to_cell:
			return _make_path_list(p_from_cell, p_to_cell, p_ignore_last_cell)
		
		# remove from open list
		open_list.erase(next['cell'])
		
		# Add new cells to try
		_add_tries(next['cell'], p_to_cell, next['g'], p_max_cost, p_ignore_last_cell)
	
	return empty_arr

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
