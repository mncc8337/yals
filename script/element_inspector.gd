extends Node


var is_dragging: bool = false
var mouse_relative_distance: Dictionary[Element, Vector2] = {};


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				var ele: Element = _get_element_under_mouse()
				if (
					Global.current_mode == Global.Mode.Normal
					and Global.current_ic
					and ele is Joint
					and ele in Global.current_ic.all_pins
					and Global.current_ic.io_pin_type_map[ele as Joint] == IC.PinType.Input
				):
					ele.value = not ele.value
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed:
				is_dragging = false
				mouse_relative_distance.clear()
			else:
				var ele: Element = _get_element_under_mouse()
				if ele:
					ele.move_to_front()
					if event.ctrl_pressed:
						if ele in Global.selected_elements:
							Global.deselect_element(ele)
						else:
							Global.select_element(ele)
					else:
						if ele not in Global.selected_elements:
							Global.clear_selected_elements()
							Global.select_element(ele)
				else:
					Global.clear_selected_elements()

	elif event is InputEventMouseMotion:
		if (
			event.button_mask & MOUSE_BUTTON_MASK_LEFT
			and not Global.selected_elements.is_empty()
			and (Global.current_mode != Global.Mode.Drawing)
		):
			var draggable: bool = true
			for e in Global.selected_elements:
				if not e.draggable:
					draggable = false
					break
			if draggable:
				var mouse_position = %Camera.get_global_mouse_position()
				if not is_dragging:
					is_dragging = true
					for e in Global.selected_elements:
						mouse_relative_distance[e] = mouse_position - e.global_position
				else:
					for e in Global.selected_elements:
						e.global_position = mouse_position - mouse_relative_distance[e]
						if e is Joint:
							e.moved.emit(e, e.global_position)
						elif e is IC:
							for j in e.all_pins:
								j.moved.emit(j, j.global_position)


func _get_element_under_mouse() -> Element:
	var space_state = %Camera.get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = %Camera.get_global_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	
	# priority:
	# joint > ic > wire
	
	var elements: Array[Element] = []
	var results = space_state.intersect_point(query)
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
	if a is Joint and b is not Joint:
		return true
	if b is Joint and a is not Joint:
		return false
	if a is Wire and b is not Wire:
		return false
	if b is Wire and a is not Wire:
		return true
	
	if a.z_index != b.z_index:
		return a.z_index > b.z_index
	
	return a.get_index() > b.get_index()
