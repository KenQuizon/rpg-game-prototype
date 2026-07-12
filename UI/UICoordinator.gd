extends Node

#class_name UICoordinator - Autoload

@onready var tooltip_manager: TooltipManager = $TooltipManager
@onready var dialog_manager: DialogManager = $DialogManager

func _ready() -> void:
	# Must keep processing input even while the tree is paused, or ESC
	# would never be able to unpause.
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	if get_tree().paused:
		unpause_game()
	else:
		pause_game()

func pause_game() -> void:
	get_tree().paused = true
	UIManager.open_panel("pause_menu")

func unpause_game() -> void:
	get_tree().paused = false
	UIManager.close_panel("pause_menu")
