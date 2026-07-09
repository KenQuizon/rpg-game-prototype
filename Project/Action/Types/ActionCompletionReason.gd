extends RefCounted
class_name ActionCompletionReason

enum Id {

	#--------------------------------------------------------------------------
	# Successful Completion
	#--------------------------------------------------------------------------

	NONE,

	COMPLETED,

	#--------------------------------------------------------------------------
	# Validation
	#--------------------------------------------------------------------------

	INVALID_REQUEST,

	FAILED_VALIDATION,

	#--------------------------------------------------------------------------
	# Runtime
	#--------------------------------------------------------------------------

	CANCELLED,

	INTERRUPTED,

	REPLACED,

	TIMEOUT,

	#--------------------------------------------------------------------------
	# Gameplay
	#--------------------------------------------------------------------------

	CHARACTER_DEAD,

	LOST_TARGET,

	OUT_OF_RANGE,

	NO_WEAPON,

	NO_RESOURCES,

	DISABLED,

	COOLDOWN,

	# Rejected by RequiredTagsPolicy — the actor currently has an active
	# status effect tag (see GameplayTags) this action forbids, e.g. an
	# attempt to cast while GameplayTags.SILENCED is active.
	FORBIDDEN_TAG,

	#--------------------------------------------------------------------------
	# System
	#--------------------------------------------------------------------------

	NETWORK,

	SYSTEM
}
