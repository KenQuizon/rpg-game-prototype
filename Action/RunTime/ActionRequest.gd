extends RefCounted
class_name ActionRequest

#==============================================================================
# Runtime Data
#==============================================================================

var context: CharacterContext

var definition: Resource

var target: Variant

var priority: int = ActionPriority.Id.NORMAL

var flags: int = ActionFlags.Id.NONE

var user_data: Variant

#==============================================================================
# Construction
#==============================================================================

func _init(
	p_context: CharacterContext,
	p_definition: Resource = null
) -> void:

	context = p_context
	definition = p_definition

	var action_definition := p_definition as ActionDefinition

	if action_definition != null:
		priority = action_definition.priority
