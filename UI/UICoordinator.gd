extends Node
class_name UICoordinator

# Coordinates between all UI systems
var ui_manager: UIManager
var tooltip_manager: TooltipManager
var dialog_manager: DialogManager
var event_system: UIEvents

func _ready() -> void:
	# Setup global access
	ui_manager = UIManager.new()
	tooltip_manager = get_node("TooltipManager")
	dialog_manager = get_node("DialogManager")
	event_system = UIEvents.new()
	
	# Connect all UI systems
	_connect_systems()

func _connect_systems() -> void:
	# Connect inventory to equipment
	# Connect skills to hotbar
	# Connect all events
	pass

func pause_game() -> void:
	get_tree().paused = true
	ui_manager.open_panel("pause_menu")

func unpause_game() -> void:
	get_tree().paused = false
	ui_manager.close_panel("pause_menu")
