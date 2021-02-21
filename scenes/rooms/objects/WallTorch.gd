extends Spatial

var player_count = 0
var was_enabled = false

func _ready():
	$Torch/Light/OmniLight.visible = false
	$Torch/Particles.emitting = false

func _check_player_count():
	if player_count == 0:
		$AnimationPlayer.play("LightOff")
		was_enabled = false
	elif !was_enabled:
		$AnimationPlayer.play("LightOn")
		was_enabled = true

func _on_PlayerDetect_body_entered(body):
	player_count = player_count + 1
	_check_player_count()

func _on_PlayerDetect_body_exited(body):
	player_count = player_count - 1
	_check_player_count()
