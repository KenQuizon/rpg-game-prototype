extends RefCounted
class_name DamageStage

#==============================================================================
# Purpose
#==============================================================================
# One step in a DamagePipeline. Override process() to read/mutate
# DamagePipelineContext.result in place, or call context.cancel() to
# short-circuit the remaining stages.
#
# Stages carry no per-character state (see DamagePipelineContext for the
# per-call data) — same convention as CombatEventHandler — so a single
# stage instance can safely be shared across every pipeline execution.

#==============================================================================
# Public API
#==============================================================================

func process(context: DamagePipelineContext) -> void:
	pass
