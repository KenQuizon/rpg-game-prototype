extends RefCounted
class_name ActionFactory


#==============================================================================
# Combat
#==============================================================================

static func create_attack() -> AttackAction:

	return AttackAction.new()
