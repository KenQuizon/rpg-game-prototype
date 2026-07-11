extends Node

#class_name UIEvents - Autoload

# Declare all signals that UI panels can emit/listen to
signal inventory_opened
signal inventory_closed
signal equipment_opened
signal equipment_closed

signal skill_selected(skill_id: String)
signal skill_used(skill_id: String)
signal skill_cooldown_started(skill_id: String, duration: float)

signal damage_applied(amount: float, is_critical: bool, world_position: Vector3)
signal healing_applied(amount: float)

signal status_effect_applied(effect_name: String)
signal status_effect_removed(effect_name: String)

signal item_picked_up(item_name: String)
signal item_used(item_name: String)
signal item_equipped(item_name: String, slot: String)

signal character_died
signal level_up(new_level: int)
