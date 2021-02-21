extends Spatial

var player_count = 0
var was_enabled = false

func _ready():
	# Turn it off by default
	$Torch/Light/OmniLight.visible = false
	$Torch/Light/OmniLight.light_energy = 0.0
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

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'LightOn':
		# start something to make lights move a bit
		pass

