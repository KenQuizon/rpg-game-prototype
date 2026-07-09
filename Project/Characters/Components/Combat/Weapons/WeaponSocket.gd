extends Node3D
class_name WeaponSocket

#==============================================================================
# Signals
#==============================================================================

signal weapon_attached(weapon: WeaponInstance)
signal weapon_detached(weapon: WeaponInstance)

#==============================================================================
# Runtime
#==============================================================================

var _current_weapon: WeaponInstance

#==============================================================================
# Properties
#==============================================================================

var current_weapon: WeaponInstance:
	get:
		return _current_weapon


func has_weapon() -> bool:
	return _current_weapon != null

#==============================================================================
# Public API
#==============================================================================

func attach(
	weapon: WeaponInstance
) -> void:

	if weapon == null:
		return

	clear()

	add_child(weapon)

	weapon.transform = Transform3D.IDENTITY

	_current_weapon = weapon

	weapon_attached.emit(weapon)


func detach() -> WeaponInstance:

	if _current_weapon == null:
		return null

	var removed := _current_weapon

	remove_child(removed)

	_current_weapon = null

	weapon_detached.emit(removed)

	return removed


func clear() -> void:

	var weapon := detach()

	if weapon != null:
		weapon.queue_free()
