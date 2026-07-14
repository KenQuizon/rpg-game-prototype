extends RefCounted
class_name UILayerType

# Ordered bottom -> top. Higher layers render/react above lower ones.
enum Id {
	HUD,      # Always-on readouts (health bars, hotbar). Not exclusive, not gameplay-blocking.
	SCREEN,   # Full-window panels the player navigates into (Inventory, Equipment, Character).
	MODAL,    # Blocking dialogs that stack on top of a screen (Pause Menu, Settings).
	POPUP,    # Transient, non-blocking overlays (confirmations, notifications).
	TOOLTIP,  # Always-on-top, single-instance, no stacking.
}

# Layers where opening a panel closes any other panel already open on that
# same layer. SCREEN and TOOLTIP are single-occupancy; MODAL and POPUP are
# allowed to stack (e.g. Settings opening on top of the Pause Menu).
const EXCLUSIVE_LAYERS: Array[Id] = [Id.SCREEN, Id.TOOLTIP]
