extends Character

class_name EnemyCharacter

export (int) var weight = 1

#############################################################################
# Character control

func became_current_character():
	# here we need to trigger our AI.. but we don't have any... so...
	GlobalState.next_character()

func unset_current_character():
	pass
