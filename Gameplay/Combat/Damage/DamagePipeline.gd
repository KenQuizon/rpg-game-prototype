extends RefCounted
class_name DamagePipeline

#==============================================================================
# Purpose
#==============================================================================
# Ordered, mutable list of DamageStage instances processed in sequence.
# Replaces the previous fixed 3-function static chain in DamageSystem —
# a new damage-affecting feature (equipment resistance, buffs/debuffs,
# elemental weaknesses) becomes a new stage inserted at the right point in
# this list, instead of an edit to a shared calculation function.
#
# Mirrors the CombatEventDispatcher.get_default() / RandomSource.get_default()
# shape already used elsewhere: a shared default pipeline for normal
# gameplay, with an explicit override point for a specific encounter/boss
# that needs a different stage list (e.g. no crits, an extra resistance
# stage) without touching the default.

#==============================================================================
# Shared Default Instance
#==============================================================================

static var _default: DamagePipeline = null

static func get_default() -> DamagePipeline:
	if _default == null:
		_default = DamagePipeline.new()
		_default._register_default_stages()
	return _default

static func set_default(pipeline: DamagePipeline) -> void:
	if pipeline == null:
		return
	_default = pipeline

#==============================================================================
# Private
#==============================================================================

var _stages: Array[DamageStage] = []

# Default order matches Objective 3 of the architectural review:
# Validation -> Critical -> [Equipment/Resistance] -> [Buffs/Debuffs] ->
# Mitigation -> Application -> Stagger -> Gameplay Events -> [Death].
# The two bracketed stages aren't implemented yet — there's no
# equipment-resistance or buff-debuff data to act on until those features
# land — but this is the ordered slot they'll insert into via insert_stage()
# when they do, rather than requiring a rewrite of this list.
func _register_default_stages() -> void:
	add_stage(DamageValidationStage.new())
	add_stage(DamageCriticalResolutionStage.new())
	add_stage(DamageMitigationStage.new())
	add_stage(DamageApplicationStage.new())
	add_stage(DamageStaggerStage.new())
	add_stage(DamageGameplayEventsStage.new())

#==============================================================================
# Stage Management
#==============================================================================

func add_stage(stage: DamageStage) -> void:
	if stage == null:
		return
	_stages.append(stage)

func insert_stage(index: int, stage: DamageStage) -> void:
	if stage == null:
		return
	_stages.insert(index, stage)

func remove_stage(stage: DamageStage) -> void:
	_stages.erase(stage)

func get_stages() -> Array[DamageStage]:
	return _stages.duplicate()

#==============================================================================
# Execution
#==============================================================================

func execute(request: DamageRequest, target: CombatComponent) -> DamageResult:

	var context := DamagePipelineContext.new(request, target)

	for stage in _stages:

		if context.cancelled:
			break

		stage.process(context)

	return context.result
