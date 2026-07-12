extends RefCounted
class_name CombatEventDispatcher
#==============================================================================
# Shared Default Instance
#==============================================================================
# Handlers carry no per-character state (see CombatEventHandler) — all
# character-specific data flows through the CharacterContext passed to
# dispatch(). That means a single shared dispatcher + handler set can safely
# serve every character in the game, avoiding a duplicate dispatcher and
# duplicate handler objects per CombatComponent instance.
static var _default: CombatEventDispatcher = null

static func get_default() -> CombatEventDispatcher:
	if _default == null:
		_default = CombatEventDispatcher.new()
		_default._register_default_handlers()
	return _default

func _register_default_handlers() -> void:
	register_handler(AnimationEvents.ENABLE_WEAPON, EnableHitboxHandler.new())
	register_handler(AnimationEvents.DISABLE_WEAPON, DisableHitboxHandler.new())
	register_handler(AnimationEvents.FINISH_ACTION, FinishActionHandler.new())
	register_handler(AnimationEvents.SPAWN_PROJECTILE, SpawnProjectileHandler.new())
	register_handler(AnimationEvents.OPEN_INTERRUPT_WINDOW, OpenInterruptWindowHandler.new())
#==============================================================================
# Private
#==============================================================================
var _handlers: Dictionary = {}
#==============================================================================
# Registration
#==============================================================================
func register_handler(
	event_name: StringName,
	handler: CombatEventHandler
) -> void:
	if handler == null:
		return
	_handlers[event_name] = handler
func unregister_handler(
	event_name: StringName
) -> void:
	_handlers.erase(event_name)
#==============================================================================
# Dispatch
#==============================================================================
func dispatch(
	event_name: StringName,
	context: CharacterContext
) -> void:
	var handler: CombatEventHandler = _handlers.get(event_name)
	if handler == null:
		return
	handler.handle_event(
		event_name,
		context
	)
