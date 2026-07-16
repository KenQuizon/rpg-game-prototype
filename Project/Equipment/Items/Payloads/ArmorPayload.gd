extends ItemPayload
class_name ArmorPayload

@export var equipment_slot: EquipmentSlotType.Id = EquipmentSlotType.Id.HEAD

@export var stat_modifiers: Array[StatModifierEntry] = []

@export var visual_scene: PackedScene

@export var armor_value: float = 0.0

# Opt-in: when non-empty, equipping this item hides the named Character
# body-part meshes and shows the corresponding meshes from inside
# visual_scene instead — used for armor that replaces the base body mesh
# (breastplates, eventually gloves/greaves) rather than attaching an
# external visual at a socket (helmets still use visual_scene alone with
# this left empty — see EquipmentComponent's two equip pathways, Stage 3).
@export var body_part_replacements: Array[BodyPartMeshMapping] = []

# Opt-in: material/texture variants applied on top of whichever mesh is
# showing for target_part once equipping finishes (after any mesh swap
# from body_part_replacements above). Independent of mesh swapping — a
# piece can reskin the base mesh without replacing it at all, or reskin
# its own replacement mesh, using the same mechanism either way.
@export var material_overrides: Array[MaterialOverride] = []
