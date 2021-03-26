extends Spatial

class_name Cell

var _character_count = 0
var _debug_enabled = false

export (Material) var default_cell_material = null
export (Material) var move_to_cell_material = null
export (Material) var cant_cell_material = null

#############################################################################
# main

func full_name() -> String:
	var room_name = get_node("../..").name
	
	return room_name + '/' + name

func is_occupied() -> bool:
	if !visible:
		# this tile is not accessible at all so we treat it as occupied
		return true
	
	if _character_count > 0:
		# a character currently occupies this cell
		return true
	
	return false

func get_neighbouring_cells() -> Array:
	# cheating a little but here these are tightly joined
	var room = get_node("../..")
	if room and room.has_method("get_neighbouring_cells"):
		return room.get_neighbouring_cells(self)
	
	return Array()

#############################################################################
# pointer interaction

enum CellStatus {
	CELL_STATUS_NOT_OVER
	CELL_STATUS_DEFAULT,
	CELL_STATUS_CAN_MOVE,
	CELL_STATUS_CANT_MOVE
}

var cell_status = CellStatus.CELL_STATUS_NOT_OVER

func set_cell_status(p_status : int):
	if $TileMesh.visible:
		cell_status = p_status
		match cell_status:
			CellStatus.CELL_STATUS_DEFAULT:
				$TileMesh.set_surface_material(0, default_cell_material)
			CellStatus.CELL_STATUS_CAN_MOVE:
				$TileMesh.set_surface_material(0, move_to_cell_material)
			CellStatus.CELL_STATUS_CANT_MOVE:
				$TileMesh.set_surface_material(0, cant_cell_material)

func _on_PointerDetect_ray_enter():
	if visible:
		$TileMesh.visible = true
		set_cell_status(CellStatus.CELL_STATUS_DEFAULT)
		GlobalState.cell_entered(self)

func _on_PointerDetect_ray_exit():
	$TileMesh.visible = false
	cell_status = CellStatus.CELL_STATUS_NOT_OVER
	GlobalState.cell_exited(self)

#############################################################################
# Character interaction

func _on_CharacterDetect_body_entered(body):
	if body.has_method("cell_entered"):
		_character_count = _character_count + 1
		if _character_count > 1:
			print("Warning, character count in cell " + name + " reached " + str(_character_count))
		body.cell_entered(self)

func _on_CharacterDetect_body_exited(body):
	if body.has_method("cell_exited"):
		body.cell_exited(self)
		_character_count = _character_count - 1

#############################################################################
# debugging

func _check_viewport():
	if !$Debug.visible and _debug_enabled:
		$Viewport.size = Vector2(250, 250)
		$Debug.visible = true

func set_g(p_text : String):
	_check_viewport()
	$Viewport/Cont/G.text = p_text

func set_h(p_text : String):
	$Viewport/Cont/H.text = p_text

func set_f(p_text : String):
	$Viewport/Cont/F.text = p_text

func mark():
	$Viewport/Cont/Name.set("custom_colors/font_color", Color("0000FF"))
	$Viewport/Cont/Name.set("custom_colors/font_outline_modulate", Color("0000DD"))
	$Viewport/Cont/G.set("custom_colors/font_color", Color("0000FF"))
	$Viewport/Cont/G.set("custom_colors/font_outline_modulate", Color("0000DD"))
	$Viewport/Cont/H.set("custom_colors/font_color", Color("0000FF"))
	$Viewport/Cont/H.set("custom_colors/font_outline_modulate", Color("0000DD"))
	$Viewport/Cont/F.set("custom_colors/font_color", Color("0000FF"))
	$Viewport/Cont/F.set("custom_colors/font_outline_modulate", Color("0000DD"))

func clear_debug():
	$Viewport.size = Vector2()
	$Debug.visible = false
	$Viewport/Cont/Name.set("custom_colors/font_color", Color("606060"))
	$Viewport/Cont/Name.set("custom_colors/font_outline_modulate", Color("000000"))
	$Viewport/Cont/G.set("custom_colors/font_color", Color("606060"))
	$Viewport/Cont/G.set("custom_colors/font_outline_modulate", Color("000000"))
	$Viewport/Cont/H.set("custom_colors/font_color", Color("606060"))
	$Viewport/Cont/H.set("custom_colors/font_outline_modulate", Color("000000"))
	$Viewport/Cont/F.set("custom_colors/font_color", Color("606060"))
	$Viewport/Cont/F.set("custom_colors/font_outline_modulate", Color("000000"))
	$Viewport/Cont/G.text = ""
	$Viewport/Cont/H.text = ""
	$Viewport/Cont/F.text = ""

#############################################################################
# private

# Called when the node enters the scene tree for the first time.
func _ready():
	# hide by default
	$TileMesh.visible = false
	
	# for debugging
	$Viewport/Cont/Name.text = full_name()
