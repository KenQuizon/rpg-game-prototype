extends Resource
class_name EquipmentProfile

#==============================================================================
# Identity
#==============================================================================

@export var display_name: String = ""

@export var slot: EquipmentSlotType.Id = EquipmentSlotType.Id.HEAD

#==============================================================================
# Stats
#==============================================================================

@export var stat_modifiers: Array[StatModifierEntry] = []

#==============================================================================
# Visual
#==============================================================================

# Optional cosmetic mesh attached to the matching EquipmentSlotSocket on
# equip. Leave null for a purely stat-granting item with no modeled
# geometry (a ring, an unmodeled amulet, etc).
@export var visual_scene: PackedScene

#==============================================================================
# Presentation (UI, future)
#==============================================================================

@export var icon: Texture2D

@export_multiline var description: String = ""
