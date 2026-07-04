extends CharacterAction
class_name AttackAction


func begin() -> void:

	super.begin()

	animation.play_attack()


func _on_animation_event(event_name: StringName) -> void:

	match event_name:

		AnimationEvents.ENABLE_WEAPON:
			print("Enable weapon")

		AnimationEvents.ATTACK_HIT:
			print("Deal damage")

		AnimationEvents.DISABLE_WEAPON:
			print("Disable weapon")

		AnimationEvents.FINISH_ACTION:
			context.action.stop_current_action()
