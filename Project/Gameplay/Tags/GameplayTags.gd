extends RefCounted
class_name GameplayTags

#==============================================================================
# Purpose
#==============================================================================
# Single source of truth for the StringNames used across the framework to
# describe "what kind of attack is this" and "what condition is this
# character currently under" — see roadmap 7.6.
#
# This does NOT replace ActionLock. ActionLock stays exactly as it is for
# movement/rotation/action/camera-type suppression (it's well-suited to
# that — see CharacterContext.is_locked()). Tags own the broader semantic
# vocabulary instead: *why* a character can't act, and categorization that
# was never a lock in the first place (attack categories, damage-type
# immunities). Two status effects can both raise the same ActionLock bit
# (e.g. Stun and Frozen both lock ACTIONS) while being distinct, queryable
# conditions via tags — that distinction is exactly what a bitmask alone
# can't express.
#
# Usage:
#   - StatusEffectData.tags (already existed) should draw from here rather
#     than ad hoc strings, so "stunned" always means the same StringName
#     everywhere it's authored.
#   - ActionPolicy can gate on tags via RequiredTagsPolicy (see
#     Characters/Components/Stats/RequiredTagsPolicy.gd) — e.g. an action
#     that's rejected while the actor has TAG_SILENCED.
#   - AttackData/DamageRequest tags (previously only CombatTags) draw from
#     the same vocabulary, so a future "immunity" damage stage can compare
#     an incoming attack's tags against a target's active condition tags
#     with one consistent set of names, not two.
#   - AI perception/targeting filters (not built yet — Phase 3) will query
#     condition tags the same way ActionPolicy does, via
#     StatusComponent.has_tag()/get_active_tags().
#
# CombatTags.gd (Characters/Components/Combat/Combat/CombatTags.gd) is
# superseded by the "Attack Categories" section below but left in place,
# unmodified, for backward compatibility — the StringName *values* are
# identical, so existing references to CombatTags.MELEE and this class's
# GameplayTags.MELEE are interchangeable at runtime. New code should
# reference GameplayTags; CombatTags is not being deleted out from under
# anything that already points at it.

#==============================================================================
# Attack Categories
#==============================================================================
# What kind of attack/damage-source this is. Same values as CombatTags,
# carried forward under the generalized vocabulary.

const PROJECTILE = &"projectile"

const MELEE = &"melee"

const SKILL = &"skill"

const SPELL = &"spell"

const AOE = &"aoe"

const EXPLOSION = &"explosion"

const HEAVY = &"heavy"

const DOT = &"dot"

const SUMMON = &"summon"

const TRAP = &"trap"

#==============================================================================
# Conditions
#==============================================================================
# What state a character is currently under. Intended to be carried on
# StatusEffectData.tags alongside whatever ActionLock bits that effect
# also sets — the lock suppresses behavior, the tag names *what it is*
# for anything (UI, AI, other policies) that needs to know which
# condition, specifically, is active.

const STUNNED = &"stunned"

const ROOTED = &"rooted"

const SILENCED = &"silenced"

const FEARED = &"feared"

const STAGGERED = &"staggered"

const KNOCKED_DOWN = &"knocked_down"

const INVULNERABLE = &"invulnerable"

#==============================================================================
# Immunities
#==============================================================================
# Carried on a character's own protective StatusEffectData (e.g. a buff or
# an innate racial/class trait), not on the incoming attack. A future
# immunity-check damage stage or ActionPolicy compares an actor's active
# immunity tags against the condition a status effect is about to apply.

const IMMUNE_TO_STUN = &"immune_to_stun"

const IMMUNE_TO_ROOT = &"immune_to_root"

const IMMUNE_TO_SILENCE = &"immune_to_silence"

const IMMUNE_TO_FEAR = &"immune_to_fear"

const IMMUNE_TO_KNOCKBACK = &"immune_to_knockback"
