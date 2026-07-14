extends Node

#class_name UIManager - Autoload

# Layered UI system: panels are grouped by UILayerType.Id (HUD, SCREEN,
# MODAL, POPUP, TOOLTIP). Multiple layers can be open simultaneously
# (e.g. a MODAL pause menu over a SCREEN inventory), while layers marked
# exclusive in UILayerType.EXCLUSIVE_LAYERS only ever have one open panel
# at a time within that layer (opening a second SCREEN panel closes the
# first).

var panels: Dictionary[String, BaseUIPanel] = {}

# layer_id -> Array[String] of panel names currently open on that layer,
# in open order (oldest first, so the last entry is the topmost panel).
var _open_by_layer: Dictionary = {}

func _ready() -> void:
	set_name("UIManager")
	# UIManager should be added as autoload in ProjectSettings
	for layer_id in UILayerType.Id.values():
		_open_by_layer[layer_id] = []

func register_panel(panel_name: String, panel: BaseUIPanel) -> void:
	"""Register a panel so UIManager can control it"""
	panels[panel_name] = panel
	print("Registered UI panel: %s (layer: %s)" % [panel_name, UILayerType.Id.keys()[panel.layer]])

func open_panel(panel_name: String) -> void:
	"""Open a specific panel, respecting its layer's stacking rules"""
	if not panel_name in panels:
		push_error("Panel not found: %s" % panel_name)
		return

	var panel := panels[panel_name]
	var layer_id := panel.layer
	var open_stack: Array = _open_by_layer[layer_id]

	if panel_name in open_stack:
		# Already open — bring to front of its layer's stack.
		open_stack.erase(panel_name)
		open_stack.append(panel_name)
		return

	if layer_id in UILayerType.EXCLUSIVE_LAYERS:
		# Close whatever else is open on this layer first.
		for other_name in open_stack.duplicate():
			panels[other_name].close()
		open_stack.clear()

	open_stack.append(panel_name)
	panel.open()
	print("Opened UI panel: %s" % panel_name)

func close_panel(panel_name: String) -> void:
	"""Close a specific panel"""
	if panel_name not in panels:
		return

	panels[panel_name].close()

	var layer_id := panels[panel_name].layer
	_open_by_layer[layer_id].erase(panel_name)

func toggle_panel(panel_name: String) -> void:
	"""Open the panel if it's closed, close it if it's open"""
	if is_panel_open(panel_name):
		close_panel(panel_name)
	else:
		open_panel(panel_name)

func is_panel_open(panel_name: String) -> bool:
	"""Check if a panel is currently open"""
	return panel_name in panels and panels[panel_name].is_open

func get_open_panels(layer_id: UILayerType.Id) -> Array[String]:
	"""Panel names currently open on a given layer, oldest to topmost"""
	var result: Array[String] = []
	for panel_name in _open_by_layer[layer_id]:
		result.append(panel_name)
	return result

func is_layer_open(layer_id: UILayerType.Id) -> bool:
	return not _open_by_layer[layer_id].is_empty()

func close_layer(layer_id: UILayerType.Id) -> void:
	"""Close every panel open on a given layer"""
	for panel_name in _open_by_layer[layer_id].duplicate():
		panels[panel_name].close()
	_open_by_layer[layer_id].clear()

func close_all() -> void:
	"""Close all open panels, on every layer"""
	for layer_id in _open_by_layer.keys():
		close_layer(layer_id)
