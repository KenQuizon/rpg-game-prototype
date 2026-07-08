extends RefCounted
class_name CombatTags

# Superseded by Core/Tags/GameplayTags.gd (roadmap 7.6), which carries
# these same StringName values forward under "Attack Categories" alongside
# a framework-wide condition/immunity vocabulary. Left in place, unchanged,
# for backward compatibility — a StringName's value is what matters at
# runtime, so CombatTags.MELEE and GameplayTags.MELEE are interchangeable.
# New code should reference GameplayTags instead of adding here.

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
