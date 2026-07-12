extends RefCounted
class_name AnimationEvents

const ATTACK_HIT = &"attack_hit"

const ENABLE_WEAPON = &"enable_weapon"
const DISABLE_WEAPON = &"disable_weapon"

const COMBO_OPEN = &"combo_open"
const COMBO_CLOSE = &"combo_close"

const FOOTSTEP_LEFT = &"footstep_left"
const FOOTSTEP_RIGHT = &"footstep_right"

const DASH_START = &"dash_start"
const DASH_END = &"dash_end"

const SPAWN_PROJECTILE = &"spawn_projectile"

const CAST_COMPLETE = &"cast_complete"

const FINISH_ACTION = &"finish_action"

# Fires at an action's "point of commitment" — after the arrow is loosed,
# after the spell is released — to open its interrupt window early. Only
# does anything for actions with ActionDefinition.delayed_interrupt_window
# = true; a no-op otherwise.
const OPEN_INTERRUPT_WINDOW = &"open_interrupt_window"
