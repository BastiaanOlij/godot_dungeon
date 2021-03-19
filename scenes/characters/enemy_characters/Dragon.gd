extends "res://scenes/characters/enemy_characters/EnemyCharacter.gd"

onready var animation_player : AnimationPlayer = $Pivot/Dragon/AnimationPlayer

var is_alive = true
var is_hit = false

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
