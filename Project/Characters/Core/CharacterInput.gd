extends RefCounted
class_name CharacterInput

var move_vector: Vector2 = Vector2.ZERO

var interact_pressed: bool = false
var interact_held: bool = false

var scroll_up_pressed: bool = false
var scroll_down_pressed: bool = false

var attack_pressed: bool = false
var attack_held: bool = false

var charged_attack_pressed: bool = false
var charged_attack_held: bool = false

var aim_mode: bool = false
var aim_world_position: Vector3 = Vector3.ZERO

var dash_pressed: bool = false

var skill_1_pressed: bool = false
