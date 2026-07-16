extends Resource
class_name MaterialOverride

# Which Character body part to re-material — same part keys
# BodyPartMeshMapping.target_part uses ("arm_left", "arm_right", "body",
# ...). Applied to whichever MeshInstance3D is currently active for that
# part, base mesh or a swapped-in replacement — see
# Character.get_character_active_body_part_mesh(). Independent of mesh
# swapping: a piece can reskin without touching body_part_replacements
# at all.
@export var target_part: String = ""

@export var material: Material

# -1 = replace the mesh's overall material_override (simplest, covers
# most reskins). 0+ = override only that specific surface index instead,
# for meshes with more than one material/surface.
@export var surface_index: int = -1
