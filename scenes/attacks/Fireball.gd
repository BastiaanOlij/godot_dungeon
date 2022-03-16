extends Attack

var target : Character
var move_speed = 0.25

func perform_attack(p_target : Character, p_spawn_point : Transform):
	target = p_target
	$MeshInstance.global_transform = p_spawn_point

	var target_pos = p_target.global_transform.origin * Vector3(1.0, 0.0, 1.0) + Vector3(0.0, p_spawn_point.origin.y, 0.0)

	var delta_move = (target_pos - p_spawn_point.origin)
	var distance = delta_move.length()
	var duration = distance * move_speed

	$Tween.interpolate_method(self, "_move_fireball", p_spawn_point.origin, target_pos, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _move_fireball(new_pos : Vector3):
	$MeshInstance.global_transform.origin = new_pos

func _on_Tween_tween_all_completed():
	target.take_damage(damage)
	emit_signal("attack_finished")
	queue_free()
