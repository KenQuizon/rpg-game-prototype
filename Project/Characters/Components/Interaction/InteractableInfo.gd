extends RefCounted
class_name InteractableInfo

#==============================================================================
# Purpose
#==============================================================================
# The one duck-typed contract every interactable can optionally implement
# via get_interact_info() -> InteractableInfo, mirroring how
# InteractionComponent.get_interact_definition() already falls back to a
# default if a target doesn't supply its own. UI never needs to know what
# kind of interactable it's looking at — only this.

# What displays in the prompt/list — an item's display_name, "Open Chest",
# "Talk", etc.
var label: String = "Interact"

# Optional icon shown next to the label. Left null for interactables that
# don't have one yet (NPCs, switches).
var icon: Texture2D = null

# Whether holding the interact button should sweep this target up
# automatically (Stage 3's gather). Defaults false so the generic
# fallback below never accidentally includes something that hasn't
# explicitly opted in — chests, doors, and NPCs stay excluded unless a
# future interactable deliberately sets this true.
var is_gatherable: bool = false


func _init(
	p_label: String = "Interact",
	p_icon: Texture2D = null,
	p_is_gatherable: bool = false
) -> void:

	label = p_label
	icon = p_icon
	is_gatherable = p_is_gatherable
