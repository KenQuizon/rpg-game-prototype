extends Resource
class_name ItemDefinition

#==============================================================================
# Identity
#==============================================================================

@export var display_name: String = ""

@export var icon: Texture2D

@export_multiline var description: String = ""

#==============================================================================
# Stacking
#==============================================================================

@export var max_stack: int = 1

@export var consumable: bool = false

@export_group("Consumable Effects")
@export var heal_amount: float = 0.0
@export var restore_resource_type: ResourceType.Id = ResourceType.Id.MANA
@export var restore_amount: float = 0.0
