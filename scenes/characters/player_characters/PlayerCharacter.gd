extends Character

class_name PlayerCharacter

export (String, DIR) var highlight_material_path

onready var animation_player : AnimationPlayer = get_node("Pivot/AnimationRig/RootNode/AnimationPlayer")

var current_move_path : Array = Array()
var moving = false;
const move_speed = 0.25

var mesh_instance_nodes : Array = Array()

var is_current = false

func _highlight_character():
	for entry in mesh_instance_nodes:
		var mesh_instance : MeshInstance = entry['node']
		for i in mesh_instance.get_surface_material_count():
			var active_material : Material = mesh_instance.get_active_material(i)
			if entry['materials'].has(active_material):
				mesh_instance.set_surface_material(i, entry['materials'][active_material])

func became_current_character():
	is_current = true
	
	# reset our turn points
	current_action_points = action_points
	emit_signal("action_points_changed", current_action_points)
	
	_do_a_star(_in_cell, GlobalState.get_current_cell())
	_highlight_character()

func unset_current_character():
	is_current = false
	$Path.visible = false
	
	for entry in mesh_instance_nodes:
		var mesh_instance : MeshInstance = entry['node']
		for i in mesh_instance.get_surface_material_count():
			mesh_instance.set_surface_material(i, null)

func pointer_cell_entered(p_cell : Cell):
	_do_a_star(_in_cell, p_cell)

func _move_character(new_pos : Vector3):
	global_transform.origin = new_pos

func _rotate_character(new_rotation : float):
	$Pivot.rotation.y = new_rotation

func perform_action():
	moving = true
	$Path.visible = false
	print("Start move")
	animation_player.play("Walk")

	while !current_move_path.empty() and current_action_points > 0:
		var next_cell : Cell = current_move_path.pop_front()
		current_action_points = current_action_points - 1
		emit_signal("action_points_changed", current_action_points)

		# determine our move
		var move_from = global_transform.origin
		var move_to = next_cell.global_transform.origin
		var delta_move = (move_to - move_from)
		var distance = delta_move.length()
		tween_node.interpolate_method(self, "_move_character", move_from, move_to, distance * move_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

		var angle_from = $Pivot.rotation.y
		var angle_to = Vector2(delta_move.x, delta_move.z).angle_to(Vector2(0, 1))
		tween_node.interpolate_method(self, "_rotate_character", angle_from, angle_to, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

		# start our tween
		tween_node.start()

		# wait for our tween to finish
		yield(tween_node, "tween_all_completed")

	print("Finished move")

	moving = false
	if current_action_points == 0:
		GlobalState.next_character()
	else:
		# init our next move
		_do_a_star(_in_cell, GlobalState.get_current_cell())

func _do_a_star(from_cell: Cell, to_cell : Cell):
	if moving:
		# already processing our move, don't do this
		print("Busy moving....")
		return
	
	if from_cell and to_cell:
		current_move_path = AstarMaze.do_astar(from_cell, to_cell, current_action_points)
	
		if !current_move_path.empty():
			to_cell.set_cell_status(Cell.CellStatus.CELL_STATUS_CAN_MOVE)
			
			# print(current_move_path)
			
			# hide spent action points
			var i : int = 1
			while i <= (action_points - current_action_points):
				var step = $Path.get_node("Step" + str(i))
				step.visible = false
				i = i + 1
			
			# show our path
			for cell in current_move_path:
				var step = $Path.get_node("Step" + str(i))
				var pos = cell.global_transform.origin
				step.global_transform.origin.x = pos.x
				step.global_transform.origin.z = pos.z
				step.visible = true
				i = i +1
				
				# just for debugging..
				cell.mark()
			
			# hide left over
			while i <= 5:
				var step = $Path.get_node("Step" + str(i))
				step.visible = false
				i = i + 1
		
			$Path.visible = true
		else:
			to_cell.set_cell_status(Cell.CellStatus.CELL_STATUS_CANT_MOVE)
			$Path.visible = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if moving and anim_name == "Walk":
		animation_player.play("Walk")

func _find_mesh_instance_nodes(parent : Node):
	var file : File = File.new()
	
	for child in parent.get_children():
		if child is MeshInstance:
			var mesh_instance : MeshInstance = child
			var entry : Dictionary = Dictionary()
			entry['node'] = mesh_instance
			entry['materials'] = Dictionary()
			
			for i in mesh_instance.get_surface_material_count():
				var active_material : Material = mesh_instance.get_active_material(i)
				var path = active_material.resource_path
				var file_name = highlight_material_path + "/" + path.get_file()
				if file.file_exists(file_name):
					var highlight_material : Material = load(file_name)
					if highlight_material:
						entry['materials'][active_material] = highlight_material
			
			if !entry['materials'].empty():
				print(mesh_instance.name)
				mesh_instance_nodes.push_back(entry)
		
		_find_mesh_instance_nodes(child)

func _ready():
	_find_mesh_instance_nodes(self)
	
	if is_current:
		_highlight_character()
