extends HBoxContainer
class_name StatusEffectContainer

@export var indicator_scene: PackedScene

var character: Character
var status_component: StatusComponent

func _ready() -> void:
	character = CharacterRef.get_player()

	if character and character.context:
		status_component = character.context.status
		if status_component:
			status_component.status_applied.connect(_on_status_applied)
			status_component.status_removed.connect(_on_status_removed)
			print("StatusEffectContainer connected")

func _on_status_applied(instance: StatusEffectInstance) -> void:
	var indicator = indicator_scene.instantiate()
	add_child(indicator)          # add first — @onready needs to be in the tree
	indicator.set_status_effect(instance)

func _on_status_removed(instance: StatusEffectInstance) -> void:
	for indicator in get_children():
		if indicator.status_effect == instance:
			indicator.queue_free()
			break
