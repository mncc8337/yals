class_name IC
extends Element


@onready var joint_scene: Resource = load("res://scene/joint.tscn")

@export var ic_name: String = "IC":
	set(val):
		if ic_name != val:
			ic_name = val
			%Label.text = val


const UNSELECT_COLOR: Color = Color(0.205, 0.205, 0.205, 1.0)
const SELECT_COLOR: Color = Color(0.427, 0.427, 0.427, 1.0)

enum PinType {
	Input,
	Output,
}

var design_mode: bool = false

var io_pin: Dictionary[PinType, Array] = {
	PinType.Input: [],
	PinType.Output: [],
}

var all_pins: Array[Joint] = []
var io_pin_type_map: Dictionary[Joint, PinType] = {}
var io_pin_name_map: Dictionary[String, Joint] = {}

var elements: Array[Element] = []


func _ready() -> void:
	if design_mode:
		visible = false
		%Area/CollisionShape.disabled = true
	else:
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	%Area/Shape.color = SELECT_COLOR


func _on_mouse_exited() -> void:
	%Area/Shape.color = UNSELECT_COLOR


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
	pin.draggable = design_mode
	pin.show_label = true
	pin.name = pin_name
	pin.value = false
	pin.associated_ic = self
	all_pins.append(pin)
	io_pin[pin_type].append(pin)
	io_pin_type_map[pin] = pin_type
	io_pin_name_map[pin_name] = pin
	
	match pin_type:
		PinType.Input:
			if not design_mode:
				pin.label_placement = Joint.LabelPlacement.Right
				%InputContainer.add_child(pin)
			else:
				pin.label_placement = Joint.LabelPlacement.Left
		PinType.Output:
			if not design_mode:
				pin.label_placement = Joint.LabelPlacement.Left
				%OutputContainer.add_child(pin)
			else:
				pin.label_placement = Joint.LabelPlacement.Right
	
	if not design_mode:
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


# an endpoint is the point that signals can not propagate further
# without going into an internal ic or going out of the current ic
func _is_endpoint(joint: Joint):
	var is_endpoint: bool = false
	var ic: IC = joint.associated_ic
	if ic:
		var pin_type: PinType = ic.io_pin_type_map[joint]
		# endpoint1: internal ic's input
		if ic != self and pin_type == PinType.Output:
			is_endpoint = true
		# endpoint2: self output
		if ic == self and pin_type == PinType.Output:
			is_endpoint = true
	return is_endpoint


func _dfs(j: Joint, visited: Dictionary[Joint, bool]) -> Array[Joint]:
	# go from start joint to all possible end joint, using dfs
	# this ensure that signal from 1 joints is propagate immediately
	# to end joints
	
	visited[j] = true

	var end_joints: Array[Joint] = []
	
	for adj_joint: Joint in j.adjacent:
		adj_joint.value = j.value
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
		elif visited.has(adj_joint):
			continue
		end_joints += _dfs(adj_joint, visited)
	return end_joints


func update_output(signal_propagating_queue: Array[Joint]) -> void:
	# use bfs to simulate signal propagation
	
	# holds log of visited joints' value
	var carry: Dictionary[Joint, bool] = {}
	
	# internal ics to update output
	var ic_update_list: Array[IC] = []
	
	for j: Joint in io_pin[PinType.Input]:
		carry[j] = j.value
		signal_propagating_queue.push_back(j)

	# use BFS to propagate signals
	while len(signal_propagating_queue):
		var joint: Joint = signal_propagating_queue.pop_front()
		var new_value: bool = joint.value
		var direct_connections: Array[Joint] = _dfs(joint, {})
			
		if len(direct_connections) == 0:
				continue

		for adj_joint: Joint in direct_connections:
			var requeue = false
			if not carry.has(adj_joint):
				requeue = true
			elif carry[adj_joint] != new_value and len(adj_joint.adjacent) > 1:
				push_error("signal conflict at joint %s (ic %s) (moving from %s (ic %s))" % [adj_joint, adj_joint.associated_ic, joint, joint.associated_ic])
				#print("%s (ic %s) -> x (conflict)" % [adj_joint, adj_joint.associated_ic])
				continue
			elif carry[adj_joint] != new_value:
				requeue = true
			
			if requeue:
				carry[adj_joint] = new_value
				adj_joint.value = new_value
				signal_propagating_queue.push_back(adj_joint)
				#print("%s (ic %s) -> %s (ic %s), making it %s" % [joint, joint.associated_ic, adj_joint, adj_joint.associated_ic, adj_joint.value])
				
				# update internal ic if propagated to its input pins
				var internal_ic = adj_joint.associated_ic
				if internal_ic and internal_ic != self and internal_ic.io_pin_type_map[adj_joint] == PinType.Input:
					if internal_ic not in ic_update_list:
						ic_update_list.push_back(internal_ic)
					#print("%s -> ic %s" % [adj_joint, internal_ic])
			#else:
				#print("%s (ic %s) -> x" % [adj_joint, adj_joint.associated_ic])
				
	for internal_ic: IC in ic_update_list:
		var original_output_value: Dictionary[Joint, bool] = {}
		for output_joint in internal_ic.io_pin[PinType.Output]:
			original_output_value[output_joint] = output_joint.value

		internal_ic.update_output(signal_propagating_queue)
		for output_joint: Joint in internal_ic.io_pin[PinType.Output]:
			if original_output_value[output_joint] != output_joint.value:
				# only requeue if the output value changed
				signal_propagating_queue.push_back(output_joint)
				carry[output_joint] = output_joint.value
				#print("ic %s -> %s, making it %s" % [internal_ic, output_joint, output_joint.value])
			#else:
				#print("%s (ic %s) -> x" % [output_joint, output_joint.associated_ic])
	
	ic_update_list.clear()


func _on_label_resized() -> void:
	%Label.position.x = %Label.size.y / 2
	%Label.position.y = -%Label.size.x / 2
