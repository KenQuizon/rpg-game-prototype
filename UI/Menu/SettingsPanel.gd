extends BaseUIPanel
class_name SettingsPanel

const SETTINGS_PATH := "user://settings.cfg"

@onready var graphics_tab: Control = $Tabs/Graphics
@onready var audio_tab: Control = $Tabs/Audio
@onready var gameplay_tab: Control = $Tabs/Gameplay

var current_tab: Control

func _ready() -> void:
	super._ready()
	UIManager.register_panel("settings", self)

	_setup_graphics_settings()
	_setup_audio_settings()
	_setup_gameplay_settings()
	_load_settings()

func _setup_graphics_settings() -> void:
	var vsync_toggle = graphics_tab.find_child("VSyncToggle")
	if vsync_toggle:
		vsync_toggle.toggled.connect(func(value):
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if value else DisplayServer.VSYNC_DISABLED)
			_save_settings()
		)

func _setup_audio_settings() -> void:
	var master_volume = audio_tab.find_child("MasterVolume")
	if master_volume:
		master_volume.value_changed.connect(func(value: float):
			var bus_idx := AudioServer.get_bus_index("Master")
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
			AudioServer.set_bus_mute(bus_idx, value <= 0.0)
			_save_settings()
		)

func _setup_gameplay_settings() -> void:
	pass

func _save_settings() -> void:
	var config := ConfigFile.new()

	var vsync_toggle = graphics_tab.find_child("VSyncToggle")
	if vsync_toggle:
		config.set_value("graphics", "vsync", vsync_toggle.button_pressed)

	var master_volume = audio_tab.find_child("MasterVolume")
	if master_volume:
		config.set_value("audio", "master_volume", master_volume.value)

	config.save(SETTINGS_PATH)

func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return

	var vsync_toggle = graphics_tab.find_child("VSyncToggle")
	if vsync_toggle and config.has_section_key("graphics", "vsync"):
		vsync_toggle.button_pressed = config.get_value("graphics", "vsync")
		vsync_toggle.toggled.emit(vsync_toggle.button_pressed)

	var master_volume = audio_tab.find_child("MasterVolume")
	if master_volume and config.has_section_key("audio", "master_volume"):
		master_volume.value = config.get_value("audio", "master_volume")
		master_volume.value_changed.emit(master_volume.value)
