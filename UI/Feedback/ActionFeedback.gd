extends VBoxContainer
class_name ActionFeedback

@export var feedback_item_scene: PackedScene
@export var max_items: int = 5

func show_feedback(message: String, feedback_type: String = "default") -> void:
	var feedback_item = feedback_item_scene.instantiate()
	feedback_item.set_message(message, feedback_type)
	add_child(feedback_item)
	
	# Remove old items if exceeding max
	if get_child_count() > max_items:
		get_child(0).queue_free()

func show_miss() -> void:
	show_feedback("MISS!", "miss")

func show_blocked() -> void:
	show_feedback("BLOCKED!", "blocked")

func show_resisted() -> void:
	show_feedback("RESISTED!", "resisted")

func show_ability_used(ability_name: String) -> void:
	show_feedback("Used %s!" % ability_name, "ability")

func show_skill_cooldown(skill_name: String, remaining: float) -> void:
	show_feedback("%s on cooldown (%.1f)s" % [skill_name, remaining], "cooldown")
