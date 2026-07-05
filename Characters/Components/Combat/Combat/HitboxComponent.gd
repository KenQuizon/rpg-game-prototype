extends BaseComponent
class_name HitboxComponent

var _combat_owner: CombatComponent = null

#==============================================================================
# Signals
#==============================================================================

signal activated
signal deactivated

#==============================================================================
# Export Variables
#==============================================================================

@export var attack_data: AttackData

#==============================================================================
# Cached Nodes
#==============================================================================

@onready var area: Area3D = $Area3D

#==============================================================================
# State
#==============================================================================

var _active := false

var _already_hit: Dictionary = {}

#==============================================================================
# Lifecycle
#==============================================================================

func on_initialize() -> void:

	if area == null:
		push_error("HitboxComponent requires an Area3D.")
		return

	area.monitoring = false

	area.set_meta(
		"hitbox_component",
		self
	)

#==============================================================================
# Public API
#==============================================================================

func activate() -> void:

	if _active:
		return

	_active = true

	_already_hit.clear()

	area.monitoring = true

	activated.emit()


func deactivate() -> void:

	if not _active:
		return

	_active = false

	area.monitoring = false

	_already_hit.clear()

	deactivated.emit()

func is_active() -> bool:
	return _active
	
func create_damage_request() -> DamageRequest:

	if attack_data == null:
		push_error("AttackData is not assigned.")
		return null

	if _combat_owner == null:
		push_error("Hitbox has no combat owner.")
		return null
	
	var builder := DamageRequestBuilder.new()

	builder \
		.attacker(_combat_owner) \
		.source(self) \
		.damage(attack_data.damage) \
		.damage_type(attack_data.damage_type) \
		.critical_multiplier(attack_data.critical_multiplier)

	for tag in attack_data.tags:
		builder.add_tag(tag)

	return builder.build()

func set_combat_owner(
	combat: CombatComponent
) -> void:

	_combat_owner = combat
