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

# Set by the currently-running AttackAction; falls back to the exported
# attack_data when null so this component still works without an Action
# driving it.
var _active_attack_data: AttackData = null

var _active_effects: AttackEffects = null

func set_active_effects(effects: AttackEffects) -> void:
	_active_effects = effects

func clear_active_effects() -> void:
	_active_effects = null
#==============================================================================
# Lifecycle
#==============================================================================
func on_initialize() -> void:
	if area == null:
		push_error("HitboxComponent requires an Area3D.")
		return
	area.monitoring = false
	area.set_meta("hitbox_component", self)
	
func get_combat_owner() -> CombatComponent:
	return _combat_owner
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

func set_active_attack_data(data: AttackData) -> void:
	_active_attack_data = data

func clear_active_attack_data() -> void:
	_active_attack_data = null
#==============================================================================
# Hit Tracking
#==============================================================================
func can_hit(hurtbox: HurtboxComponent) -> bool:
	if hurtbox == null:
		return false
	return not _already_hit.has(hurtbox.get_instance_id())
func register_hit(hurtbox: HurtboxComponent) -> void:
	if hurtbox == null:
		return
	_already_hit[hurtbox.get_instance_id()] = true

	if _active_effects != null:
		CombatEffects.play_vfx(_active_effects.impact_vfx, area.global_position, get_tree())
		CombatEffects.play_sfx(_active_effects.hit_sfx, area.global_position, get_tree())
#==============================================================================
# Damage Requests
#==============================================================================
func create_damage_request() -> DamageRequest:

	var data := _active_attack_data if _active_attack_data != null else attack_data

	if data == null:
		print("[HITBOX BUG] owner=", _combat_owner.owner_character.name if _combat_owner and _combat_owner.owner_character else "unknown",
			" current_anim=", _combat_owner.owner_character.get_character_animation_player().current_animation if _combat_owner and _combat_owner.owner_character.has_method("get_character_animation_player") else "?")
		push_error("HitboxComponent has no AttackData (no active attack and no default assigned).")
		return null
		
	if _combat_owner == null:
		push_error("Hitbox has no combat owner.")
		return null

	var builder := DamageRequestBuilder.new()
	builder \
		.attacker(_combat_owner) \
		.source(self) \
		.damage(data.damage) \
		.damage_type(data.damage_type) \
		.critical_multiplier(data.critical_multiplier) \
		.can_be_blocked(data.can_be_blocked) \
		.can_be_evaded(data.can_be_evaded) \
		.can_stagger(data.can_stagger) \
		.stagger_damage(data.stagger_damage) \
		.stagger_effect(data.stagger_effect)
	for tag in data.tags:
		builder.add_tag(tag)
	return builder.build()
func set_combat_owner(
	combat: CombatComponent
) -> void:
	_combat_owner = combat
