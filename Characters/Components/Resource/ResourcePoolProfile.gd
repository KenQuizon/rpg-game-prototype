extends Resource
class_name ResourcePoolProfile

#==============================================================================
# Identity
#==============================================================================

@export var resource_type: ResourceType.Id = ResourceType.Id.MANA

#==============================================================================
# Values
#==============================================================================

@export_range(0.0, 9999.0)
var max_value: float = 100.0

@export_range(0.0, 999.0)
var regen_per_second: float = 5.0

@export var start_full: bool = true
