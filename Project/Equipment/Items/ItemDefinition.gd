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
