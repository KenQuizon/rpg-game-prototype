extends HBoxContainer
class_name StatusEffectContainer

@export var indicator_scene: PackedScene

var character: Character
var status_component: Node

func _ready() -> void:
	character = CharacterRef.get_player()
	
	if character and character.has_method("get_character_status"):
		status_component = character.get_character_status()
		status_component.status_effect_applied.connect(_on_status_applied)
		status_component.status_effect_removed.connect(_on_status_removed)
		print("StatusEffectContainer connected")

func _on_status_applied(effect: StatusEffectInstance) -> void:
	"""New status effect applied"""
	var indicator = indicator_scene.instantiate()
	indicator.set_status_effect(effect)
	add_child(indicator)

func _on_status_removed(effect: StatusEffectInstance) -> void:
	"""Status effect removed"""
	for indicator in get_children():
		if indicator.status_effect == effect:
			indicator.queue_free()
			break
