extends PanelContainer
class_name PickupNotificationRow

@onready var icon_rect: TextureRect = $HBoxContainer/Icon
@onready var name_label: Label = $HBoxContainer/NameLabel

const HOLD_DURATION: float = 2.0
const FADE_DURATION: float = 0.3

var item: ItemDefinition
var _quantity: int = 0
var _hold_remaining: float = 0.0
var _fading: bool = false


# Called once, right after instantiation. Starts the fade-in and the
# hold countdown — same shape as DamageNumber.setup() / 
# StatusEffectIndicator.set_status_effect().
func setup(new_item: ItemDefinition, quantity: int) -> void:

	item = new_item
	_quantity = quantity

	icon_rect.texture = item.icon
	icon_rect.visible = item.icon != null

	_update_label()

	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)

	_hold_remaining = HOLD_DURATION


# Called by PickupNotificationUI when the same item is picked up again
# while this row is still alive — bumps the count and restarts the hold
# timer, without restarting the fade-in (it's already visible).
func add_quantity(delta: int) -> void:
	_quantity += delta
	_update_label()
	_hold_remaining = HOLD_DURATION


func _process(delta: float) -> void:

	if _fading:
		return

	_hold_remaining -= delta

	if _hold_remaining <= 0.0:
		_fade_out()


func _update_label() -> void:
	name_label.text = "%s x%d" % [item.display_name, _quantity] if _quantity > 1 else item.display_name


func _fade_out() -> void:
	_fading = true
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	await tween.finished
	queue_free()
