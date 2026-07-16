extends BaseComponent
class_name EquipmentComponent

#==============================================================================
# Signals
#==============================================================================

signal equipment_equipped(slot: int, item: ItemDefinition)
signal equipment_unequipped(slot: int, item: ItemDefinition)

#==============================================================================
# Export Variables
#==============================================================================

@export var default_equipment: Array[ItemDefinition] = []

#==============================================================================
# Runtime
#==============================================================================

var _equipped: Dictionary = {} # EquipmentSlotType.Id -> EquippedItem
var _sockets: Dictionary = {} # EquipmentSlotType.Id -> EquipmentSlotSocket

# EquipmentSlotType.Id -> Array[MeshInstance3D], the replacement meshes
# currently reparented onto the skeleton for that slot. Presence of a key
# here is how _detach_visual() tells the two equip pathways apart — see
# _attach_body_part_replacements().
var _replacement_meshes: Dictionary = {}

# EquipmentSlotType.Id -> Array[String], the part names this slot's
# currently-equipped item has a material override active on — used to
# clear the right overrides on unequip without touching parts other
# equipment might also be overriding.
var _material_override_parts: Dictionary = {}

#==============================================================================
# Lifecycle
#==============================================================================

func on_initialize() -> void:

	if not owner_character.has_method("get_character_visual"):
		return

	_discover_sockets(owner_character.get_character_visual())

	for item in default_equipment:
		equip(item)

func _discover_sockets(node: Node) -> void:

	if node == null:
		return

	for child in node.get_children():

		if child is EquipmentSlotSocket:
			_sockets[child.slot] = child

		_discover_sockets(child)

#==============================================================================
# Public API
#==============================================================================

func equip(item: ItemDefinition) -> bool:

	if item == null:
		return false

	var slot: int
	var payload: ItemPayload

	if item.payload is ArmorPayload:
		var armor := item.payload as ArmorPayload
		slot = armor.equipment_slot
		payload = armor
	elif item.payload is AccessoryPayload:
		var accessory := item.payload as AccessoryPayload
		slot = accessory.equipment_slot
		payload = accessory
	else:
		push_error("ItemDefinition '%s' has no Armor/Accessory payload." % item.display_name)
		return false

	unequip(slot)

	var equipped := EquippedItem.new(item, payload, slot)

	_equipped[slot] = equipped

	_apply_modifiers(equipped)

	_attach_visual(equipped)

	equipment_equipped.emit(slot, item)

	return true

func unequip(slot: int) -> void:

	if not _equipped.has(slot):
		return

	var equipped: EquippedItem = _equipped[slot]

	_remove_modifiers(equipped)

	_detach_visual(equipped)

	_equipped.erase(slot)

	equipment_unequipped.emit(slot, equipped.item)

func unequip_all() -> void:
	for slot in _equipped.keys().duplicate():
		unequip(slot)

func get_equipped(slot: int) -> ItemDefinition:

	if not _equipped.has(slot):
		return null

	var equipped: EquippedItem = _equipped[slot]

	return equipped.item

func has_equipped(slot: int) -> bool:
	return _equipped.has(slot)

#==============================================================================
# Internal — Stat Modifiers
#==============================================================================

func _apply_modifiers(equipped: EquippedItem) -> void:

	var stats := context.stats

	if stats == null:
		return

	var modifiers: Array = equipped.payload.get("stat_modifiers")

	if modifiers == null or modifiers.is_empty():
		return

	for entry: StatModifierEntry in modifiers:
		stats.add_modifier(
			entry.stat,
			StatModifier.new(equipped, entry.value)
		)

func _remove_modifiers(equipped: EquippedItem) -> void:

	var stats := context.stats

	if stats == null:
		return

	stats.remove_modifiers_from_source(equipped)

#==============================================================================
# Internal — Visuals
#==============================================================================

func _attach_visual(equipped: EquippedItem) -> void:

	# body_part_replacements is only present on ArmorPayload, and only
	# non-empty for armor that swaps base body meshes (breastplate, later
	# gloves/greaves). Everything else — helmets, accessories — falls
	# through to the socket-attach pathway instead.
	var replacements: Array = equipped.payload.get("body_part_replacements")

	if replacements != null and not replacements.is_empty():
		_attach_body_part_replacements(equipped, replacements)
	else:
		var visual_scene: PackedScene = equipped.payload.get("visual_scene")

		if visual_scene != null:
			var socket: EquipmentSlotSocket = _sockets.get(equipped.slot)

			if socket != null:
				var visual := visual_scene.instantiate() as Node3D
				if visual != null:
					socket.attach(visual)

	# Runs after either pathway above, so overrides always land on
	# whichever mesh ended up active for target_part — the just-swapped
	# replacement mesh, or the untouched base mesh if this item doesn't
	# swap meshes at all.
	_apply_material_overrides(equipped)

func _detach_visual(equipped: EquippedItem) -> void:

	# Runs before either pathway below, while the active mesh for each
	# overridden part is still the one the override was actually applied
	# to (matters most when that mesh is the base mesh, which isn't freed
	# and would otherwise keep the override forever).
	_clear_material_overrides(equipped)

	if _replacement_meshes.has(equipped.slot):
		_detach_body_part_replacements(equipped)
		return

	var socket: EquipmentSlotSocket = _sockets.get(equipped.slot)

	if socket != null:
		socket.clear()

#==============================================================================
# Internal — Body-Part Mesh Replacement
#==============================================================================
# Unlike the socket pathway (attach a whole scene as one child), this hides
# specific base-body MeshInstance3Ds and reparents specific meshes from
# inside visual_scene directly under the real Skeleton3D — required because
# those meshes' own `skeleton` NodePath (set to "..") only resolves
# correctly if their direct parent IS the Skeleton3D. See BodyPartMeshMapping.

func _attach_body_part_replacements(equipped: EquippedItem, replacements: Array) -> void:

	var visual_scene: PackedScene = equipped.payload.get("visual_scene")

	if visual_scene == null:
		push_error(
			"ArmorPayload for '%s' has body_part_replacements but no visual_scene." % equipped.item.display_name
		)
		return

	if not owner_character.has_method("get_character_skeleton") \
		or not owner_character.has_method("get_character_body_part_mesh"):
		push_error("Character does not expose get_character_skeleton()/get_character_body_part_mesh().")
		return

	var skeleton: Skeleton3D = owner_character.get_character_skeleton()

	if skeleton == null:
		push_error("Character skeleton is null — cannot equip body-part-replacement armor.")
		return

	var wrapper := visual_scene.instantiate() as Node3D

	if wrapper == null:
		push_error("ArmorPayload visual_scene for '%s' did not instantiate as a Node3D." % equipped.item.display_name)
		return

	var can_track_active_mesh: bool = owner_character.has_method("set_character_active_body_part_mesh")

	var attached_meshes: Array[MeshInstance3D] = []

	for mapping: BodyPartMeshMapping in replacements:

		var source := wrapper.find_child(mapping.source_node_name, false, false) as MeshInstance3D

		if source == null:
			push_error(
				"BodyPartMeshMapping: source node '%s' not found in visual_scene for '%s'." % [
					mapping.source_node_name, equipped.item.display_name
				]
			)
			continue

		var original: MeshInstance3D = owner_character.get_character_body_part_mesh(mapping.target_part)

		if original == null:
			push_error(
				"BodyPartMeshMapping: target_part '%s' did not resolve on Character." % mapping.target_part
			)
			continue

		wrapper.remove_child(source)
		skeleton.add_child(source)

		original.visible = false

		if can_track_active_mesh:
			owner_character.set_character_active_body_part_mesh(mapping.target_part, source)

		attached_meshes.append(source)

	# Only the named meshes were pulled out for reparenting — the wrapper
	# itself (and anything left inside it) is no longer needed.
	wrapper.queue_free()

	_replacement_meshes[equipped.slot] = attached_meshes

func _detach_body_part_replacements(equipped: EquippedItem) -> void:

	var replacements: Array = equipped.payload.get("body_part_replacements")

	var can_reset_active_mesh: bool = owner_character.has_method("reset_character_active_body_part_mesh")
	var can_get_base_mesh: bool = owner_character.has_method("get_character_body_part_mesh")

	if replacements != null:
		for mapping: BodyPartMeshMapping in replacements:

			if can_get_base_mesh:
				var original: MeshInstance3D = owner_character.get_character_body_part_mesh(mapping.target_part)
				if original != null:
					original.visible = true

			if can_reset_active_mesh:
				owner_character.reset_character_active_body_part_mesh(mapping.target_part)

	var attached_meshes: Array = _replacement_meshes.get(equipped.slot, [])

	for mesh in attached_meshes:
		if is_instance_valid(mesh):
			mesh.queue_free()

	_replacement_meshes.erase(equipped.slot)

#==============================================================================
# Internal — Material Overrides
#==============================================================================
# Reskins/recolors whichever mesh is currently active for a part — works
# whether that's the base mesh or a mesh swapped in by
# _attach_body_part_replacements above, and independently of it (an item
# can carry material_overrides with no body_part_replacements at all).

func _apply_material_overrides(equipped: EquippedItem) -> void:

	var overrides: Array = equipped.payload.get("material_overrides")

	if overrides == null or overrides.is_empty():
		return

	if not owner_character.has_method("apply_character_material_override"):
		return

	var applied_parts: Array[String] = []

	for override: MaterialOverride in overrides:

		owner_character.apply_character_material_override(
			override.target_part,
			override.material,
			override.surface_index
		)

		applied_parts.append(override.target_part)

	_material_override_parts[equipped.slot] = applied_parts

func _clear_material_overrides(equipped: EquippedItem) -> void:

	if not _material_override_parts.has(equipped.slot):
		return

	if owner_character.has_method("clear_character_material_override"):

		var overrides: Array = equipped.payload.get("material_overrides")
		var surface_index_by_part: Dictionary = {}

		if overrides != null:
			for override: MaterialOverride in overrides:
				surface_index_by_part[override.target_part] = override.surface_index

		for part_name in _material_override_parts[equipped.slot]:
			var surface_index: int = surface_index_by_part.get(part_name, -1)
			owner_character.clear_character_material_override(part_name, surface_index)

	_material_override_parts.erase(equipped.slot)

#==============================================================================
# Save/Load
#==============================================================================

func save_state() -> Dictionary:
	var data := {}
	for slot in _equipped.keys():
		var equipped: EquippedItem = _equipped[slot]
		data[str(slot)] = equipped.item.resource_path
	return data

func load_state(data: Dictionary) -> void:
	unequip_all()
	for key in data.keys():
		var item := load(data[key]) as ItemDefinition
		if item != null:
			equip(item)
