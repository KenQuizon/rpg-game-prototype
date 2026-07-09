extends RefCounted
class_name InteractionDomainContext

#==============================================================================
# Purpose
#==============================================================================
# Groups InteractionComponent as its own domain. Single-member today, but
# kept separate rather than folded into another domain because World
# systems (Phase 5 — quests, dialogue) are expected to extend interaction
# independently (e.g. dialogue-triggering interactables, quest-gated
# interactables) without touching combat, vitals, or mobility.

#==============================================================================
# Private
#==============================================================================

var _registry: ComponentRegistry

#==============================================================================
# Initialization
#==============================================================================

func _init(registry: ComponentRegistry) -> void:
	_registry = registry

#==============================================================================
# Typed Components
#==============================================================================

var interaction: InteractionComponent:
	get:
		return _registry.get_component(InteractionComponent) as InteractionComponent
