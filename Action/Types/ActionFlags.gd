extends RefCounted
class_name ActionFlags

enum Id {

	NONE = 0,

	QUEUEABLE = 1 << 0,

	INTERRUPTIBLE = 1 << 1,

	CAN_QUEUE_WHILE_RUNNING = 1 << 2,

	REQUIRES_TARGET = 1 << 3,

	REQUIRES_WEAPON = 1 << 4,

	REQUIRES_GROUND = 1 << 5,

	IGNORE_GLOBAL_LOCKS = 1 << 6,

	SERVER_ONLY = 1 << 7,

	CLIENT_ONLY = 1 << 8
}
