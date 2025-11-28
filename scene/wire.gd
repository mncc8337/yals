class_name Wire
extends Line2D


@export var joints: Array[Joint] = []

const INACTIVE_COLOR: Color = Color("#545454")
const ACTIVE_COLOR: Color = Color("#ff6969")
const SELECT_COLOR: Color = Color("#e3e3e3")


func _ready() -> void:
	default_color = INACTIVE_COLOR
	global_position = Vector2.ZERO
	add_point(Vector2.ZERO)
	add_point(Vector2.ZERO)
	default_color = INACTIVE_COLOR


func add_joint(joint: Joint):
	if len(joints) >= 2:
		return
	joints.append(joint)
	joint.toggled.connect(_on_joint_toggled)
	joint.moved.connect(_on_joint_moved)
	set_point_position(len(joints) - 1, joint.global_position)


func _on_joint_toggled(value) -> void:
	if value:
		default_color = ACTIVE_COLOR
	else:
		default_color = INACTIVE_COLOR


func _on_joint_moved(joint: Joint, new_pos: Vector2):
	if joint == joints[0]:
		set_point_position(0, new_pos)
	else:
		set_point_position(1, new_pos)
