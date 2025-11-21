@tool
class_name Joint
extends Element


const INACTIVE_COLOR: Color = Color("#8a8a8a")
const ACTIVE_COLOR: Color = Color("#ff6969")

enum LabelPlacement {
	UP,
	DOWN,
	LEFT,
	RIGHT
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

var show_label: bool = true:
	set(val):
		if show_label != val:
			show_label = val
var label_placement: LabelPlacement = LabelPlacement.RIGHT
var label_offset: float = 21.0


func _ready() -> void:
	%Area/Shape.color = INACTIVE_COLOR
	%Label.visible = show_label
	%Label.text = self.name
	update_placement()


func update_placement() -> void:
	match label_placement:
		LabelPlacement.UP:
			%Label.position.x = -%Label.size.x / 2
			%Label.position.y = -label_offset - %Label.size.y
			%Label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
			%Label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_BOTTOM
		LabelPlacement.DOWN:
			%Label.position.x = -%Label.size.x / 2
			%Label.position.y = label_offset
			%Label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
			%Label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_TOP
		LabelPlacement.RIGHT:
			%Label.position.y = -%Label.size.y / 2
			%Label.position.x = label_offset
			%Label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
			%Label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
		LabelPlacement.LEFT:
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
