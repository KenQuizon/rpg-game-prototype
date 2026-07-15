extends CharacterCommand
class_name GatherCommand

#==============================================================================
# Validation
#==============================================================================

func can_execute() -> bool:

	if context.interaction == null:
		return false

	if context.is_locked(ActionLock.Id.INTERACTION):
		return false

	return true

#==============================================================================
# Execution
#==============================================================================

# Not a new interaction mechanism — sweeps everything currently nearby
# that opts into is_gatherable and fires the same begin_interaction() /
# complete_interaction() pair InteractAction already calls for a single
# target, just called N times. This is why a chest, NPC, or anything
# else that already works with tap-interact needs zero changes to also
# work with gather — it either opts in via is_gatherable or it doesn't.
func execute() -> bool:

	if not can_execute():
		return false

	var nearby := context.interaction.get_ordered_nearby()

	if nearby.is_empty():
		return false

	var gathered_any := false

	for target: Node in nearby:

		var info := context.interaction.get_interactable_info(target)

		if not info.is_gatherable:
			continue

		context.interaction.begin_interaction(target)
		context.interaction.complete_interaction(target)

		gathered_any = true

	return gathered_any
