extends ItemPayload
class_name ArmorPayload

@export var equipment_slot: EquipmentSlotType.Id = EquipmentSlotType.Id.HEAD

@export var stat_modifiers: Array[StatModifierEntry] = []

@export var visual_scene: PackedScene

@export var armor_value: float = 0.0
