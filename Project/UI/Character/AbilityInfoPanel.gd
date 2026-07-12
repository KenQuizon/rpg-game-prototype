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

	skill_name.text = skill.display_name
	description.text = skill.description
	icon.texture = skill.icon

	cooldown_label.text = "%.1fs" % skill.cooldown if skill.cooldown > 0.0 else "No cooldown"

	var cost := _get_resource_cost(skill)
	if cost:
		cost_label.text = "%d %s" % [int(cost.amount), ResourceType.Id.keys()[cost.resource_type].capitalize()]
	else:
		cost_label.text = "Free"

	if skill.attack_data:
		damage_info.text = "Damage: %d" % int(skill.attack_data.damage)
		damage_info.visible = true
	else:
		damage_info.visible = false

func _get_resource_cost(skill: SkillDefinition) -> ResourceCostPolicy:
	for policy in skill.policies:
		if policy is ResourceCostPolicy:
			return policy
	return null
