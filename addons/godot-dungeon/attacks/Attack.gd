extends Spatial

class_name Attack

signal attack_finished

export var damage : int = 1.0

func perform_attack(p_target : Character, p_spawn_point : Transform):
	p_target.take_damage(damage)
	emit_signal("attack_finished")
