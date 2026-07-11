extends BaseUIPanel
class_name AbilityInfoPanel

@onready var skill_name: Label = $VBoxContainer/Name
@onready var description: RichTextLabel = $VBoxContainer/Description
@onready var cooldown_label: Label = $VBoxContainer/CooldownValue
@onready var cost_label: Label = $VBoxContainer/CostValue
@onready var icon: TextureRect = $VBoxContainer/Icon
@onready var damage_info: Label = $VBoxContainer/DamageInfo

var current_skill: SkillDefinition

func display_skill(skill: SkillDefinition) -> void:
	current_skill = skill
	
	skill_name.text = skill.name
	description.text = skill.description if skill.has_meta("description") else ""
	
	# Display resource cost
	if skill.has_meta("resource_cost"):
		cost_label.text = "%d Mana" % int(skill.get_meta("resource_cost"))
	
	# Display cooldown
	if skill.has_meta("cooldown"):
		cooldown_label.text = "%.1fs" % float(skill.get_meta("cooldown"))
	
	# Display damage if applicable
	if skill.has_meta("damage"):
		damage_info.text = "Damage: %d" % int(skill.get_meta("damage"))
	
	# Display icon
	if skill.has_meta("icon"):
		icon.texture = skill.get_meta("icon")
