extends ActionDefinition
class_name InteractDefinition

#==============================================================================
# Presentation
#==============================================================================

@export var interact_animation: StringName = &""

#==============================================================================
# Notes
#==============================================================================

# duration (inherited from ActionDefinition) is what distinguishes an
# instant interaction from a channeled one:
#   - duration <= 0.0 (default): performs immediately on submit — a lever,
#     a pickup, a door.
#   - duration > 0.0: the interactable only actually triggers once the
#     duration elapses uninterrupted — a shrine, a long-press terminal.
#     Breaking it early (damage, a higher-priority action preempting it)
#     cancels it and it never fires. See InteractAction.
#
# Remember to set action_script to InteractAction.gd, same as an
# AttackDefinition resource must point at AttackAction.gd.
