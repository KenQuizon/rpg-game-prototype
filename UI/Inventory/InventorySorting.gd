extends Control
class_name InventorySorting

# Rarity/Weight/Type/Value removed — ItemDefinition doesn't have those
# fields yet. Add them there first if you want to sort/filter by them.
enum SortMode { NAME, QUANTITY }

@onready var sort_dropdown: OptionButton = $SortDropdown

var current_sort: SortMode = SortMode.NAME

func _ready() -> void:
	sort_dropdown.item_selected.connect(_on_sort_changed)
	sort_dropdown.add_item("Name", SortMode.NAME)
	sort_dropdown.add_item("Quantity", SortMode.QUANTITY)

func apply_sort(slots: Array[InventorySlot]) -> Array[InventorySlot]:
	match current_sort:
		SortMode.NAME:
			slots.sort_custom(func(a, b): return a.item.display_name < b.item.display_name)
		SortMode.QUANTITY:
			slots.sort_custom(func(a, b): return a.quantity > b.quantity)

	return slots

func _on_sort_changed(index: int) -> void:
	current_sort = sort_dropdown.get_item_id(index)
