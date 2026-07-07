extends BaseComponent
class_name SkillComponent

#==============================================================================
# Export Variables
#==============================================================================

@export var known_skills: Array[SkillDefinition] = []

#==============================================================================
# Queries
#==============================================================================

func get_skill(id: StringName) -> SkillDefinition:

	for skill in known_skills:

		if skill != null and skill.id == id:
			return skill

	return null


func has_skill(id: StringName) -> bool:
	return get_skill(id) != null
