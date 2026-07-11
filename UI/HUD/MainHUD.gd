extends CanvasLayer
class_name MainHUD

@onready var health_bar: Control = $PlayerStats/HealthBar
@onready var mana_bar: Control = $PlayerStats/ManaBar
@onready var stamina_bar: Control = $PlayerStats/StaminaBar
@onready var target_stats: Control = $TargetStats
@onready var action_feed: VBoxContainer = $ActionFeed

var current_target: Character

func _ready() -> void:
	# HUD is always visible
	self.layer = 50  # Layer value for HUD
	
	# Setup target panel (hidden by default)
	target_stats.visible = false
	
	# Listen for character death
	UIEvents.character_died.connect(_on_character_died)
	
	print("MainHUD initialized")

func set_target(target: Character) -> void:
	"""Set which character's stats to display (for targeting)"""
	current_target = target
	
	if not target:
		target_stats.visible = false
		return
	
	target_stats.visible = true
	# Update target display here

func _on_character_died() -> void:
	"""Called when player dies"""
	# Show death screen or respawn options
	pass
