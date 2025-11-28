@tool
class_name IC
extends Element


@onready var joint_scene: Resource = load("res://scene/joint.tscn")

@export var ic_name: String = "IC":
	set(val):
		if ic_name != val:
			ic_name = val
			%Label.text = val

enum PinType {
	Input,
	Output,
}

var io_pin: Dictionary[PinType, Array] = {
	PinType.Input: [],
	PinType.Output: [],
}

var io_pin_type_map: Dictionary[Joint, PinType] = {}
var io_pin_name_map: Dictionary[String, Joint] = {}

var elements: Array[Element] = []

var direct_connect: Dictionary[Joint, Array] = {}


func _resize_container(container: Node2D, available_size: float) -> void:
	var children: Array[Node] = container.get_children()
	var children_count: float = container.get_child_count()
	
	if children_count == 0:
		return
	
	if children_count == 1:
		children[0].position.y = 0
		return
	
	for i: int in range(children_count):
		var child: Node2D = children[i]
		child.position.y = available_size * (i / (children_count - 1.0) - 0.5)

func add_pin(pin_name: String, pin_type: PinType) -> Joint:
	var pin: Joint = joint_scene.instantiate()
	pin.draggable = false
	pin.show_label = true
	pin.name = pin_name
	pin.value = false
	pin.associated_ic = self
	io_pin[pin_type].append(pin)
	io_pin_type_map[pin] = pin_type
	io_pin_name_map[pin_name] = pin
	
	match pin_type:
		PinType.Input:
			pin.label_placement = Joint.LabelPlacement.Right
			%InputContainer.add_child(pin)
		PinType.Output:
			pin.label_placement = Joint.LabelPlacement.Left
			%OutputContainer.add_child(pin)
	
	var max_height: float = max(len(io_pin[PinType.Input]), len(io_pin[PinType.Output]))
	
	# resize shape and containers
	var spacing: float = 42.0
	var padding: float = 32.0
	var content_size: float = (max_height - 1) * spacing
	%Area.scale.y = (content_size + padding * 2) / 120.0
	_resize_container(%InputContainer, content_size)
	_resize_container(%OutputContainer, content_size)

	return pin


func set_pin(pin_name: String, value: bool) -> void:
	assert(io_pin_name_map.has(pin_name), "IC %s does not has pin %s" % [self.name, pin_name])
	io_pin_name_map[pin_name].value = value


func get_pin(pin_name: String) -> Joint:
	assert(io_pin_name_map.has(pin_name), "IC %s does not has pin %s" % [self.name, pin_name])
	return io_pin_name_map[pin_name]


func add_element(el: Element) -> void:
	elements.append(el)


func _dfs(j: Joint, visited: Dictionary[Joint, bool]) -> Array[Joint]:
	# search for direct connections from one joint to
	# all possible input joints
	# or its output joints
	
	visited[j] = true

	var end_joints: Array[Joint] = []
	
	for adj_joint: Joint in j.adjacent:
		var is_endpoint = false
		var ic = adj_joint.associated_ic
		if ic:
			var pin_type = ic.io_pin_type_map[adj_joint]
			# endpoint1: external ic input pin
			if ic != self and pin_type == PinType.Input:
				is_endpoint = true
			# endpoint2: this ic output pin
			if ic == self and pin_type == PinType.Output:
				is_endpoint = true
				
		if is_endpoint:
			end_joints.append(adj_joint)
		else:
			if visited.has(adj_joint):
				continue
			end_joints += _dfs(adj_joint, visited)
	return end_joints


func make_graph() -> void:
	# ommit intermediate joints to make the signal propagation even and faster
	direct_connect.clear()

	var pins: Array = io_pin[PinType.Input]

	# add ICs' output pin to the calculation
	for e in elements:
		if e is not IC:
			continue
		pins += e.io_pin[PinType.Output]
	
	for j: Joint in pins:
		if len(j.adjacent) == 0:
			continue
		var end_joint = _dfs(j, {})
		direct_connect[j] = end_joint


func update_output() -> void:
	# use bfs to simulate signal propagation
	
	var signal_propagating_queue: Array[Joint] = []
	
	# holds log of visited joints' value
	var carry: Dictionary[Joint, bool] = {}
	
	# internal ics to update output
	var ic_update_list: Array[IC] = []
	
	for j: Joint in io_pin[PinType.Input]:
		carry[j] = j.value
		signal_propagating_queue.push_back(j)

	while true:
		while len(signal_propagating_queue):
			var joint: Joint = signal_propagating_queue.pop_front()
			var new_value: bool = joint.value
			
			if not direct_connect.has(joint):
				continue
			
			for adj_joint: Joint in direct_connect[joint]:
				var requeue = false
				if not carry.has(adj_joint):
					requeue = true
				elif carry[adj_joint] != new_value and len(adj_joint.adjacent) > 1:
					push_error("signal conflict at joint %s (ic %s) (moving from %s (ic %s))" % [adj_joint, adj_joint.associated_ic, joint, joint.associated_ic])
					print("%s (ic %s) -> x (conflict)" % [adj_joint, adj_joint.associated_ic])
					continue
				elif carry[adj_joint] != new_value:
					requeue = true
				
				if requeue:
					carry[adj_joint] = new_value
					adj_joint.value = new_value
					signal_propagating_queue.push_back(adj_joint)
					print("%s (ic %s) -> %s (ic %s), making it %s" % [joint, joint.associated_ic, adj_joint, adj_joint.associated_ic, adj_joint.value])
					
					# update internal ic if propagated to its input pins
					var internal_ic = adj_joint.associated_ic
					if internal_ic and internal_ic != self and internal_ic.io_pin_type_map[adj_joint] == PinType.Input:
						if internal_ic not in ic_update_list:
							ic_update_list.push_back(internal_ic)
						print("%s -> ic %s" % [adj_joint, internal_ic])
				else:
					print("%s (ic %s) -> x" % [adj_joint, adj_joint.associated_ic])
					
		for internal_ic: IC in ic_update_list:
			var original_output_value: Dictionary[Joint, bool] = {}
			for output_joint in internal_ic.io_pin[PinType.Output]:
				original_output_value[output_joint] = output_joint.value

			internal_ic.update_output()
			for output_joint: Joint in internal_ic.io_pin[PinType.Output]:
				if original_output_value[output_joint] != output_joint.value:
					# only requeue if the output value changed
					signal_propagating_queue.push_back(output_joint)
					carry[output_joint] = output_joint.value
					print("ic %s -> %s, making it %s" % [internal_ic, output_joint, output_joint.value])
				else:
					print("%s (ic %s) -> x" % [output_joint, output_joint.associated_ic])
		
		ic_update_list.clear()
		
		# repeat until queue is empty
		if len(signal_propagating_queue) == 0:
			break


func _on_label_resized() -> void:
	%Label.position.x = %Label.size.y / 2
	%Label.position.y = -%Label.size.x / 2
