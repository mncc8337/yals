@tool
class_name Joint
extends Element


signal toggled(state: bool)
signal moved(new_position: Vector2)

const INACTIVE_COLOR: Color = Color("#8a8a8a")
const ACTIVE_COLOR: Color = Color("#ff9999")
const SELECT_COLOR: Color = Color("#e3e3e3")

enum LabelPlacement {
	Up,
	Down,
	Left,
	Right
}

var adjacent: Array[Joint] = []
# indicate if this joint belongs to an ic or not
var associated_ic: IC = null
var value: bool:
	set(val):
		if value != val:
			value = val
			if value:
				%Area/Shape.color = ACTIVE_COLOR
			else:
				%Area/Shape.color = INACTIVE_COLOR
			toggled.emit(val)

var show_label: bool = true:
	set(val):
		if show_label != val:
			show_label = val
			%Label.visible = show_label
var label_placement: LabelPlacement = LabelPlacement.Right
var label_offset: float = 21.0

var prev_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	%Area/Shape.color = INACTIVE_COLOR
	%Label.visible = show_label
	%Label.text = self.name
	update_placement()
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _process(_delta: float) -> void:
	if prev_position != global_position:
		prev_position = global_position
		moved.emit(self, global_position)


func _on_mouse_entered() -> void:
	%Area/Shape.color = SELECT_COLOR


func _on_mouse_exited() -> void:
	%Area/Shape.color = INACTIVE_COLOR


func update_placement() -> void:
	match label_placement:
		LabelPlacement.Up:
			%Label.position.x = -%Label.size.x / 2
			%Label.position.y = -label_offset - %Label.size.y
			%Label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
			%Label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_BOTTOM
		LabelPlacement.Down:
			%Label.position.x = -%Label.size.x / 2
			%Label.position.y = label_offset
			%Label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
			%Label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_TOP
		LabelPlacement.Right:
			%Label.position.y = -%Label.size.y / 2
			%Label.position.x = label_offset
			%Label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
			%Label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
		LabelPlacement.Left:
			%Label.position.y = -%Label.size.y / 2
			%Label.position.x = -label_offset - %Label.size.x
			%Label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT
			%Label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER


func make_connection(joint: Joint) -> void:
	assert(not(joint in adjacent), "joint is connected")
	adjacent.append(joint)
	joint.adjacent.append(self)


func remove_connection(joint: Joint) -> void:
	assert(joint in adjacent, "joint isnt connected")
	adjacent.erase(joint)
	joint.erase(self)


func split(middle_joint: Joint, end_joint_id: int) -> void:
	assert(end_joint_id < len(adjacent) || end_joint_id >= 0, "invalid end_joint_id")
	var end_joint = adjacent[end_joint_id]
	adjacent[end_joint_id] = middle_joint
	middle_joint.adjacent.append(self)
	middle_joint.adjacent.append(end_joint)
	end_joint.adjacent.erase(self)
	end_joint.adjacent.append(middle_joint)
