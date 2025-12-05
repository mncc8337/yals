@tool
class_name Joint
extends Element


signal toggled(state: bool)
signal moved(joint: Joint, new_position: Vector2)

const SELECT_COLOR: Dictionary[bool, Color] = {
	true: Color("#ff9999"),
	false: Color("#e3e3e3"),
}

const deselect_COLOR: Dictionary[bool, Color] = {
	true: Color("#ff5a5a"),
	false: Color("#8a8a8a"),
}

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
			%Area/Shape.color = deselect_COLOR[value]
			toggled.emit()

var show_label: bool = true:
	set(val):
		if show_label != val:
			show_label = val
			%Label.visible = show_label
			if show_label:
				%Area.scale = Vector2(1.0, 1.0)
			else:
				%Area.scale = Vector2(0.5, 0.5)
var label_placement: LabelPlacement = LabelPlacement.Right
var label_offset: float = 21.0


func _ready() -> void:
	%Area/Shape.color = deselect_COLOR[value]
	%Label.visible = show_label
	%Label.text = self.name
	update_placement()
	
	selected.connect(_on_selected)
	deselected.connect(_on_deselected)


func _on_selected() -> void:
	%Area/Shape.color = SELECT_COLOR[value]


func _on_deselected() -> void:
	%Area/Shape.color = deselect_COLOR[value]


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
	joint.adjacent.erase(self)


func split(middle_joint: Joint, end_joint_id: int) -> void:
	assert(end_joint_id < len(adjacent) || end_joint_id >= 0, "invalid end_joint_id")
	var end_joint = adjacent[end_joint_id]
	adjacent[end_joint_id] = middle_joint
	middle_joint.adjacent.append(self)
	middle_joint.adjacent.append(end_joint)
	end_joint.adjacent.erase(self)
	end_joint.adjacent.append(middle_joint)
