extends Node


var is_dragging: bool = false
var mouse_relative_distance: Vector2


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed:
				if is_dragging:
					is_dragging = false
					
			else:
				var ele: Element = _get_element_under_mouse()
				Global.selecting_element = ele
				if ele:
					ele.move_to_front()
					print("selecting ", ele)
					if (
						Global.current_mode == Global.Mode.Normal
						and Global.current_ic
						and Global.current_ic.io_pin_type_map.has(ele)
						and Global.current_ic.io_pin_type_map[ele as Joint] == IC.PinType.Input
					):
						ele.value = not ele.value
				else:
					print("deselected")
	elif event is InputEventMouseMotion:
		var draggable: bool = Global.selecting_element and Global.selecting_element.draggable
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT and draggable:
			if not is_dragging:
				is_dragging = true
				mouse_relative_distance = Global.selecting_element.global_position - %Camera.get_global_mouse_position()
				print("dragging ", Global.selecting_element)
				
				if (
					Global.current_ic
					and Global.current_ic.io_pin_type_map.has(Global.selecting_element)
					and Global.current_ic.io_pin_type_map[Global.selecting_element as Joint] == IC.PinType.Input
				):
					Global.selecting_element.value = not Global.selecting_element.value
			else:
				var new_pos = %Camera.get_global_mouse_position() + mouse_relative_distance
				Global.selecting_element.global_position = new_pos
				if Global.selecting_element is Joint:
					Global.selecting_element.moved.emit(Global.selecting_element, new_pos)
				elif Global.selecting_element is IC:
					for j in Global.selecting_element.io_pin_type_map.keys():
						j.moved.emit(j, j.global_position)


func _get_element_under_mouse() -> Element:
	var space_state = %Camera.get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = %Camera.get_global_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	
	var results = space_state.intersect_point(query)
	var elements: Array[Element] = []
	for result in results:
		var ele = result.collider.get_parent()
		if ele is not Element:
			continue
		elements.append(ele)
	
	if elements.is_empty():
		return null
	
	elements.sort_custom(_sort_element)
	
	return elements[0]


func _sort_element(a: Element, b: Element) -> bool:
	if a.z_index != b.z_index:
		return a.z_index > b.z_index
	
	return a.get_index() > b.get_index()
