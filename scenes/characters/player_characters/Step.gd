tool
extends Spatial

export (Texture) var texture = null setget set_texture

var material : SpatialMaterial = null

func set_texture(p_new_texture):
	texture = p_new_texture
	if material:
		material.albedo_texture = texture

# Called when the node enters the scene tree for the first time.
func _ready():
	material = $MeshInstance.get_surface_material(0)
	set_texture(texture)
