class_name Wire
extends Element


@export var joints: Array[Joint] = []

const SELECT_COLOR: Dictionary[bool, Color] = {
	true: Color("#ff9999"),
	false: Color("#e3e3e3"),
}

const UNSELECT_COLOR: Dictionary[bool, Color] = {
	true: Color("#ff5a5a"),
	false: Color("#8a8a8a"),
}

var value: bool = false


func _ready() -> void:
	%Line.default_color = UNSELECT_COLOR[value]
	global_position = Vector2.ZERO
	%Line.add_point(Vector2.ZERO)
	%Line.add_point(Vector2.ZERO)
	mouse_entered.connect(_on_mouse_entered)
	%Area/CollisionShape.disabled = true
	draggable = false


func add_joint(joint: Joint):
	if len(joints) >= 2:
		return
	if len(joints) == 1:
		if joint == joints[0]:
			return
	joints.append(joint)
	joint.toggled.connect(_on_joint_toggled)
	joint.moved.connect(_on_joint_moved)
	%Line.set_point_position(len(joints) - 1, joint.global_position)
	
	if len(joints) == 2:
		joints[0].make_connection(joints[1])
		%Area/CollisionShape.disabled = false
		_update_collision_shape()


func set_end_position(new_pos: Vector2) -> void:
	%Line.set_point_position(1, new_pos)


func _on_joint_toggled() -> void:
	value = joints[0].value and joints[1].value
	%Line.default_color = UNSELECT_COLOR[value]


func _on_joint_moved(joint: Joint, new_pos: Vector2):
	if joint == joints[0]:
		%Line.set_point_position(0, new_pos)
	else:
		%Line.set_point_position(1, new_pos)
	_update_collision_shape()

func _update_collision_shape():
	var p1 = %Line.get_point_position(0)
	var p2 = %Line.get_point_position(1)

	var center = (p1 + p2) / 2
	var angle = (p2 - p1).angle()
	var length = p1.distance_to(p2)

	%Area/CollisionShape.position = center
	%Area/CollisionShape.rotation = angle
	%Area/CollisionShape.shape.size = Vector2(length, %Line.width)


func _on_mouse_entered() -> void:
	%Line.default_color = SELECT_COLOR[value]


func _on_area_mouse_exited() -> void:
	%Line.default_color = UNSELECT_COLOR[value]
