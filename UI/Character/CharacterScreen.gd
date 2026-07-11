extends BaseUIPanel
class_name CharacterScreen

@onready var character_model: Node3D = $CharacterPreview
@onready var character_name: Label = $Info/Name
@onready var stats_panel: VBoxContainer = $Info/Stats
@onready var perks_panel: VBoxContainer = $Info/Perks
@onready var equipment_panel: VBoxContainer = $Info/Equipment

var character: Character

func _ready() -> void:
	super._ready()
	character = get_tree().root.get_node("World/Player")
	
	if character:
		_update_character_display()
		
		# Add character model preview
		_create_character_preview()

func _create_character_preview() -> void:
	# Clone character model for display
	if character.has_method("get_character_model"):
		var model = character.get_character_model().duplicate()
		character_model.add_child(model)

func _update_character_display() -> void:
	character_name.text = character.name
	# Update all information
	pass
