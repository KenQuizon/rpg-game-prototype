extends BaseUIPanel
class_name SettingsPanel

@onready var graphics_tab: Control = $Tabs/Graphics
@onready var audio_tab: Control = $Tabs/Audio
@onready var gameplay_tab: Control = $Tabs/Gameplay

var current_tab: Control

func _ready() -> void:
	super._ready()
	
	# Setup graphics settings
	_setup_graphics_settings()
	
	# Setup audio settings
	_setup_audio_settings()
	
	# Setup gameplay settings
	_setup_gameplay_settings()

func _setup_graphics_settings() -> void:
	var vsync_toggle = graphics_tab.find_child("VSyncToggle")
	if vsync_toggle:
		vsync_toggle.toggled.connect(func(value): DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if value else DisplayServer.VSYNC_DISABLED))

func _setup_audio_settings() -> void:
	var master_volume = audio_tab.find_child("MasterVolume")
	if master_volume:
		master_volume.value_changed.connect(func(value): AudioServer.set_bus_mute(0, value == 0))

func _setup_gameplay_settings() -> void:
	# Difficulty, controls, etc.
	pass
