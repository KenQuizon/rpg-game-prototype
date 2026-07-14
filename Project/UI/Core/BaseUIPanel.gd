extends Control
class_name BaseUIPanel

signal panel_opened
signal panel_closed

## Which UI layer this panel belongs to. Subclasses should set this in
## _ready(), before calling super._ready(), e.g.:
##   func _ready() -> void:
##       layer = UILayerType.Id.MODAL
##       super._ready()
var layer: UILayerType.Id = UILayerType.Id.SCREEN

var is_open: bool = false
var tween: Tween

func _ready() -> void:
	visible = false
	is_open = false

func open(animate: bool = true) -> void:
	is_open = true
	visible = true
	
	if animate:
		if tween:
			tween.kill()
		tween = create_tween()
		modulate.a = 0
		tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
	panel_opened.emit()

func close(animate: bool = true) -> void:
	is_open = false
	
	if animate:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.3)
		await tween.finished
	
	visible = false
	panel_closed.emit()

func toggle(animate: bool = true) -> void:
	if is_open:
		close(animate)
	else:
		open(animate)
