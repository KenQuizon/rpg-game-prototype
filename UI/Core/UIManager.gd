extends Node

#class_name UIManager - Autoload

# Singleton for managing all UI panels
var panels: Dictionary[String, BaseUIPanel] = {}
var active_panel: String = ""

func _ready() -> void:
	set_name("UIManager")
	# UIManager should be added as autoload in ProjectSettings

func register_panel(panel_name: String, panel: BaseUIPanel) -> void:
	"""Register a panel so UIManager can control it"""
	panels[panel_name] = panel
	print("Registered UI panel: %s" % panel_name)

func open_panel(panel_name: String) -> void:
	"""Open a specific panel"""
	if not panel_name in panels:
		push_error("Panel not found: %s" % panel_name)
		return
	
	# Close current panel if different
	if active_panel != "" and active_panel != panel_name:
		if active_panel in panels:
			panels[active_panel].close()
	
	active_panel = panel_name
	panels[panel_name].open()
	print("Opened UI panel: %s" % panel_name)

func close_panel(panel_name: String) -> void:
	"""Close a specific panel"""
	if panel_name not in panels:
		return
	
	panels[panel_name].close()
	if active_panel == panel_name:
		active_panel = ""

func is_panel_open(panel_name: String) -> bool:
	"""Check if a panel is currently open"""
	return panel_name in panels and panels[panel_name].is_open

func close_all() -> void:
	"""Close all open panels"""
	for panel_name in panels:
		panels[panel_name].close()
	active_panel = ""
