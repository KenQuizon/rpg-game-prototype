extends Control
class_name InventorySorting

enum SortMode { NAME, RARITY, WEIGHT, TYPE, VALUE }

@onready var sort_dropdown: OptionButton = $SortDropdown
@onready var filter_buttons: HBoxContainer = $FilterButtons

var current_sort: SortMode = SortMode.NAME
var active_filters: Array[String] = []

func _ready() -> void:
	sort_dropdown.item_selected.connect(_on_sort_changed)
	
	# Add sort options
	sort_dropdown.add_item("Name", SortMode.NAME)
	sort_dropdown.add_item("Rarity", SortMode.RARITY)
	sort_dropdown.add_item("Weight", SortMode.WEIGHT)
	sort_dropdown.add_item("Type", SortMode.TYPE)
	sort_dropdown.add_item("Value", SortMode.VALUE)

func apply_sort(items: Array[ItemDefinition]) -> Array[ItemDefinition]:
	match current_sort:
		SortMode.NAME:
			items.sort_custom(func(a, b): return a.name < b.name)
		SortMode.RARITY:
			items.sort_custom(func(a, b): return a.get_meta("rarity", 0) > b.get_meta("rarity", 0))
		SortMode.WEIGHT:
			items.sort_custom(func(a, b): return a.get_meta("weight", 0) < b.get_meta("weight", 0))
		SortMode.TYPE:
			items.sort_custom(func(a, b): return a.get_meta("type", "") < b.get_meta("type", ""))
		SortMode.VALUE:
			items.sort_custom(func(a, b): return a.get_meta("value", 0) > b.get_meta("value", 0))
	
	return items

func apply_filters(items: Array[ItemDefinition]) -> Array[ItemDefinition]:
	if active_filters.is_empty():
		return items
	
	return items.filter(func(item): return item.get_meta("type", "") in active_filters)

func add_filter(filter_type: String) -> void:
	if not filter_type in active_filters:
		active_filters.append(filter_type)

func remove_filter(filter_type: String) -> void:
	active_filters.erase(filter_type)

func _on_sort_changed(index: int) -> void:
	current_sort = sort_dropdown.get_item_id(index)
