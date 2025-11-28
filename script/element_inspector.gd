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
				else:
					print("deselected")
	elif event is InputEventMouseMotion:
		var draggable: bool = Global.selecting_element and Global.selecting_element.draggable
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT and draggable:
			if not is_dragging:
				is_dragging = true
				mouse_relative_distance = Global.selecting_element.global_position - event.global_position
				print("dragging ", Global.selecting_element)
			else:
				Global.selecting_element.global_position = event.position + mouse_relative_distance


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
	var a_is_joint = a is Joint
	var b_is_joint = b is Joint
	
	if a_is_joint != b_is_joint:
		return a_is_joint

	if a.z_index != b.z_index:
		return a.z_index > b.z_index
	
	return a.get_index() > b.get_index()
