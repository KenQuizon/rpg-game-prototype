extends CharacterAction
class_name AttackAction

#==============================================================================
# Runtime
#==============================================================================

var _weapon: WeaponComponent
var _attack: AttackDefinition

var _watched_clip: StringName = &""

#==============================================================================
# Validation
#==============================================================================

func can_execute() -> bool:

	_weapon = context.weapon

	if _weapon == null:
		print("[COMBAT] AttackAction.can_execute() - weapon is null")
		return false

	if not _weapon.has_weapon():
		print("[COMBAT] AttackAction.can_execute() - no weapon equipped")
		return false

	_attack = _weapon.select_next_attack()

	if _attack == null:
		print("[COMBAT] AttackAction.can_execute() - attack selection returned null")
		return false

	print("[COMBAT] ✅ AttackAction.can_execute() SUCCESS")
	print("[COMBAT]   - Attack ID: ", _attack.id)
	print("[COMBAT]   - Projectile Scene: ", _attack.projectile_scene)
	print("[COMBAT]   - Action Script: ", _attack.action_script)
	print("[COMBAT]   - Animation: ", _attack.animation)

	return true

#==============================================================================
# Lifecycle
#==============================================================================

func on_start() -> void:

	super.on_start()

	context.combat.begin_attack()

	print("[COMBAT] AttackAction.on_start() starting")
	print("[COMBAT]   - Attack: ", _attack.id if _attack else "null")
	print("[COMBAT]   - Has Projectile: ", _attack.projectile_scene != null if _attack else "no attack")
	
	_apply_attack_data()
	_apply_motion()
	_face_target()
	_play_attack_animation()
	
	print("[COMBAT]   - Attack data applied and animation started")

func on_update(_delta: float) -> int:
	_face_target()
	return ActionExecutionStatus.Id.RUNNING

# Fires immediately when FINISH_ACTION (or the duration safety net) asks
# this action to wind down — stops dealing damage and stops forced motion
# right away, while get_recovery_time() below holds the action's locks a
# bit longer.
func on_finish_requested() -> void:
	print("[COMBAT] AttackAction.on_finish_requested() - FINISH_ACTION event received")
	context.combat.finish_attack()
	_clear_attack_data()
	_clear_motion()

func get_recovery_time() -> float:
	if _attack == null or _attack.timing == null:
		return 0.0
	return _attack.timing.recovery_time

# Once this attack becomes preemptible (see ActionDefinition.
# delayed_interrupt_window), it also no longer needs to hold movement/
# rotation hostage — a released arrow doesn't care if the ranger starts
# walking away immediately after. Locks are a separate mechanism from
# preemption (see ActionScheduler.release_locks), so both need updating.
# INPUT is the important one here: PlayerController/AIController check
# context.is_locked(INPUT) before building ANY command (attack, evade,
# skill, interact) — leaving it held means no new action ever reaches
# ActionScheduler.submit() for is_interruptible() to even be asked about,
# which is why the window "opening" alone wasn't enough to make anything
# feel responsive.
func open_interrupt_window() -> void:
	super.open_interrupt_window()
	context.action.release_locks(
		ActionLock.Id.MOVEMENT
		| ActionLock.Id.ROTATION
		| ActionLock.Id.INPUT
	)

func on_finish() -> void:
	# Safety net — idiopotent, guarantees clean state even if
	# on_finish_requested() never ran (e.g. duration timeout with no
	# FINISH_ACTION event at all).
	print("[COMBAT] AttackAction.on_finish() - final cleanup")
	context.combat.finish_attack()
	_clear_attack_data()
	_clear_motion()
	super.on_finish()

#==============================================================================
# Internal
#==============================================================================

func _play_attack_animation() -> void:

	if _attack == null:
		return

	if _attack.animation.is_empty():
		animation.play_attack()
		return

	animation.play(
		_attack.animation,
		true
	)

	_watch_for_completion(_attack.animation)

# Finishes this action as soon as the clip it's watching actually plays
# through — no duration timer, no dependency on a "finish_action"
# animation event that doesn't exist yet. request_finish() then still
# goes through the normal on_finish_requested() → recovery_time →
# on_finish() pipeline exactly as before, so nothing about that changes;
# this only fixes *when* completion gets triggered in the first place.
func _watch_for_completion(clip_name: StringName) -> void:
	_watched_clip = clip_name
	if not animation.animation_finished.is_connected(_on_watched_animation_finished):
		animation.animation_finished.connect(_on_watched_animation_finished, CONNECT_ONE_SHOT)

func _on_watched_animation_finished(finished_name: StringName) -> void:
	if finished_name != _watched_clip:
		return
	request_finish()

func _play_attack_effects() -> void:
	if _attack == null or _attack.effects == null:
		return
	CombatEffects.play_vfx(
	_attack.effects.slash_vfx,
	context.character.global_position,
	context.character.get_tree()
	)

	CombatEffects.play_sfx(
	_attack.effects.attack_sfx,
	context.character.global_position,
	context.character.get_tree()
	)
	
func _apply_attack_data() -> void:

	if _attack == null:
		return

	var hitbox := context.combat.get_hitbox()

	if hitbox != null:
		hitbox.set_active_attack_data(_attack.attack_data)
		hitbox.set_active_effects(_attack.effects)

	print("[COMBAT] _apply_attack_data(): setting projectile")
	print("[COMBAT]   - Scene: ", _attack.projectile_scene)
	print("[COMBAT]   - Data: ", _attack.attack_data)
	context.combat.set_active_projectile(_attack.projectile_scene, _attack.attack_data)

func _clear_attack_data() -> void:
	print("[COMBAT] _clear_attack_data() - CLEARING projectile at t=", Time.get_ticks_msec())
	var hitbox := context.combat.get_hitbox()

	if hitbox != null:
		hitbox.clear_active_attack_data()
		hitbox.clear_active_effects()

	context.combat.clear_active_projectile()

# Wires AttackMotion.move_distance/move_speed only — allow_rotation and
# stop_movement_input are superseded by ActionDefinition.locks (ROTATION/
# MOVEMENT, built in Phase 4) and are intentionally left unwired to avoid
# two competing switches for the same behavior.
func _apply_motion() -> void:

	if _attack == null or _attack.motion == null:
		return

	var movement := context.movement

	if movement == null:
		return

	if _attack.motion.move_distance > 0.0 and _attack.motion.move_speed > 0.0:
		movement.apply_attack_motion(
			_attack.motion.move_distance,
			_attack.motion.move_speed
		)

func _clear_motion() -> void:

	var movement := context.movement

	if movement != null:
		movement.clear_attack_motion()

# Mobile Legends-style auto-face: if there's an enemy within this weapon's
# attack range, snap to face it (character + attack direction both follow
# — SpawnProjectileHandler asks the same question with the same range, so
# a ranged attack's projectile never disagrees with which way the
# character is visually facing). If there's no target in range, this is
# simply a no-op — facing_direction is left exactly as movement input last
# set it, so the attack plays toward wherever the character already faces.
func _face_target() -> void:

	if context.targeting == null or _weapon == null:
		return

	var target := context.targeting.get_target_within_range(_weapon.get_attack_range())

	if target == null:
		return

	context.movement.face_point(target.global_position)
