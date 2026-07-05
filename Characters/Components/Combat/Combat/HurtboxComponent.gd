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

	if not other.owner is HitboxComponent:
		return

	var hitbox := other.owner as HitboxComponent

	hit_received.emit(hitbox)

	_receive_hit(hitbox)

#==============================================================================
# Internal
#==============================================================================

func _receive_hit(hitbox: HitboxComponent) -> void:

	if not hitbox.is_active():
		return

	if not hitbox.can_hit(self):
		return

	hitbox.register_hit(self)

	var request := hitbox.create_damage_request()

	damage_received.emit(request)

	_combat.receive_damage(request)
