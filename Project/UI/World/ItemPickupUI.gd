extends Control
class_name ItemPickupUI

@onready var prompt_label: Label = $PromptLabel

func _ready() -> void:
	visible = false

	var character := CharacterRef.get_player()
	if character and character.context and character.context.interaction:
		character.context.interaction.interaction_target_changed.connect(_on_target_changed)

func _on_target_changed(_previous: Node, new_target: Node) -> void:
	if new_target == null:
		visible = false
		return

	if new_target is WorldItem and new_target.item is ItemDefinition:
		prompt_label.text = "Press F to pick up %s" % new_target.item.display_name
	elif new_target.has_method("interact"):
		prompt_label.text = "Press F to interact"
	else:
		visible = false
		return

	visible = true
