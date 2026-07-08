extends BaseComponent
class_name HurtboxComponent

#==============================================================================
# Signals
#==============================================================================

signal damage_received(request: DamageRequest)

signal hit_received(hitbox: HitboxComponent)

#==============================================================================
# Cached Components
#==============================================================================

@onready var area: Area3D = $Area3D

var _combat: CombatComponent

#==============================================================================
# Lifecycle
#==============================================================================

func on_initialize() -> void:

	_combat = context.combat

	if area == null:
		push_error("HurtboxComponent requires an Area3D.")
		return

	if not area.area_entered.is_connected(_on_area_entered):
		area.area_entered.connect(_on_area_entered)

#==============================================================================
# Area Events
#==============================================================================

func _on_area_entered(other: Area3D) -> void:
	print("[Hurtbox] entered by: ", other.name,
		" | owner path: ", other.get_path(),
		" | has_meta: ", other.has_meta("hitbox_component"),
		" | other layer/mask: ", other.collision_layer, "/", other.collision_mask,
		" | my layer/mask: ", area.collision_layer, "/", area.collision_mask)

	if not other.has_meta("hitbox_component"):
		return

	var hitbox := other.get_meta("hitbox_component") as HitboxComponent

	if hitbox == null:
		return

	hit_received.emit(hitbox)

	_receive_hit(hitbox)

#==============================================================================
# Internal
#==============================================================================

func _receive_hit(hitbox: HitboxComponent) -> void:

	print("[Hurtbox] _receive_hit — is_active: ", hitbox.is_active(), " can_hit: ", hitbox.can_hit(self))

	if not hitbox.is_active():
		return

	if not hitbox.can_hit(self):
		return

	hitbox.register_hit(self)

	var request := hitbox.create_damage_request()

	print("[Hurtbox] request built: ", request)

	damage_received.emit(request)

	_combat.receive_damage(request)
