class_name Joint
extends Element

var adjacent: Array[Joint] = []
# indicate if this joint belongs to an ic or not
var associated_ic: IC = null
var value: bool:
	set(val):
		if value != val:
			value = val

func _init(joint_name: String, init_value: bool = false) -> void:
	name = joint_name
	value = init_value

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
