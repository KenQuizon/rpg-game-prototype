extends RefCounted
class_name MobilityDomainContext

#==============================================================================
# Purpose
#==============================================================================
# Groups spatial components: input-driven locomotion (MovementComponent)
# and AI-driven pathing/targeting (NavigationComponent, TargetingComponent).
# This is the deliberate seed of the Phase 3 AIContext the roadmap calls
# for ("AIContext domain context should own targeting+navigation+
# perception jointly, since AI is the first system that needs all three
# simultaneously") — when AI Perception is built, it becomes a fourth
# member here rather than a new flat CharacterContext property, and
# AIController can depend on this one domain object instead of three
# separate accessors.

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

var movement: MovementComponent:
	get:
		return _registry.get_component(MovementComponent) as MovementComponent

var navigation: NavigationComponent:
	get:
		return _registry.get_component(NavigationComponent) as NavigationComponent

var targeting: TargetingComponent:
	get:
		return _registry.get_component(TargetingComponent) as TargetingComponent
