extends RefCounted
class_name ActionLock

enum Id {

	NONE = 0,

	MOVEMENT = 1 << 0,

	ROTATION = 1 << 1,

	ACTIONS = 1 << 2,

	ATTACK = 1 << 3,

	SKILLS = 1 << 4,

	INTERACTION = 1 << 5,

	EQUIPMENT = 1 << 6,

	INPUT = 1 << 7,

	CAMERA = 1 << 8,

	ALL = 0x7FFFFFFF
}
