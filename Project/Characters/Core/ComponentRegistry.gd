extends RefCounted
class_name ComponentRegistry

#==============================================================================
# Private Variables
#==============================================================================

var _components: Dictionary = {}

#==============================================================================
# Registration
#==============================================================================

func register_component(component: BaseComponent) -> void:
	_components[component.get_component_key()] = component


func unregister_component(component: BaseComponent) -> void:
	_components.erase(component.get_component_key())

#==============================================================================
# Lookup
#==============================================================================

func get_component(component_class) -> BaseComponent:
	return _components.get(component_class)


func has_component(component_class) -> bool:
	return _components.has(component_class)

#==============================================================================
# Utility
#==============================================================================

func get_all_components() -> Array[BaseComponent]:
	var result: Array[BaseComponent] = []

	for component in _components.values():
		result.append(component)

	return result


func clear() -> void:
	_components.clear()
