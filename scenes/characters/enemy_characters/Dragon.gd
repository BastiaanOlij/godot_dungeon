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
