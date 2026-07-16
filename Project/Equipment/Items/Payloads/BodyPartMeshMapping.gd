extends Resource
class_name BodyPartMeshMapping

# Name of the MeshInstance3D child inside the payload's visual_scene
# (e.g. "Knight_ArmLeft" inside IronBreastplate.tscn).
@export var source_node_name: String = ""

# Which Character body part this mesh replaces when equipped — must
# match the keys Character._body_part_meshes uses (see
# Character.get_character_body_part_mesh(), Stage 1). E.g. "arm_left",
# "arm_right", "body".
@export var target_part: String = ""
