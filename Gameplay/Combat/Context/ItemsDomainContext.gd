extends RefCounted
class_name ItemsDomainContext

#==============================================================================
# Purpose
#==============================================================================
# Groups EquipmentComponent as its own domain — the seed of the Phase 5
# InventoryContext the roadmap calls for. Equipment is the only
# item-adjacent component that exists yet; when InventoryComponent lands,
# it becomes a second member here (equipment + inventory share the same
# "items" domain), rather than a new flat CharacterContext property.

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

var equipment: EquipmentComponent:
	get:
		return _registry.get_component(EquipmentComponent) as EquipmentComponent
		
var inventory: InventoryComponent:
	get:
		return _registry.get_component(InventoryComponent) as InventoryComponent
