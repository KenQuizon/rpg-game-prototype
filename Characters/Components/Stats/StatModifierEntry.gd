extends Resource
class_name StatModifierEntry

#==============================================================================
# Data
#==============================================================================

# A single authorable (stat, value) pair. Exists because StatModifier
# (the runtime type StatsComponent actually applies) is a RefCounted, and
# RefCounted types can't be authored as typed @export Resource arrays in
# the inspector. StatusEffectData exports an Array[StatModifierEntry]; at
# runtime, StatusComponent converts each entry into a real StatModifier.

@export var stat: StatType.Id = StatType.Id.STRENGTH

@export var value: float = 0.0
