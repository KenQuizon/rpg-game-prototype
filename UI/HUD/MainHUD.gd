extends CanvasLayer
class_name MainHUD

@onready var health_bar: Control = $PlayerStats/VBoxContainer/HealthBar
@onready var mana_bar: Control = $PlayerStats/VBoxContainer/ManaBar
@onready var stamina_bar: Control = $PlayerStats/StaminaBar
@onready var target_stats: Control = $TargetStats
@onready var action_feed: ActionFeedback = $ActionFeed
@onready var cast_bar: CastBar = $CastBar
@onready var status_effects: StatusEffectContainer = $StatusEffects

var current_target: Character

func _ready() -> void:
	self.layer = 50

	if target_stats:
		target_stats.visible = false

	UIEvents.character_died.connect(_on_character_died)
	print("MainHUD initialized")

func set_target(target: Character) -> void:
	current_target = target
	if target_stats:
		target_stats.visible = target != null

func _on_character_died() -> void:
	pass
