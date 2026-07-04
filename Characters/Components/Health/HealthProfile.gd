extends Resource
class_name HealthProfile

#==============================================================================
# Base Health
#==============================================================================

@export_range(1.0, 999999.0)
var max_health: float = 100.0

@export
var start_at_full_health: bool = true

@export_range(0.0, 9999.0)
var starting_health: float = 100.0

#==============================================================================
# Regeneration
#==============================================================================

@export
var enable_regeneration: bool = false

@export_range(0.0, 9999.0)
var regeneration_per_second: float = 0.0
