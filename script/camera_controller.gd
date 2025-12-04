extends Node


var is_dragging: bool = false
var last_mouse_position: Vector2

var zoom_speed: float = 1.1


func _input(event: InputEvent) -> void:
	# camera drag
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if not event.pressed:
				is_dragging = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_to_mouse(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_to_mouse(-1)
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			if not is_dragging:
				is_dragging = true
				last_mouse_position = event.global_position
				print("dragging camera")
			else:
				%Camera.global_position -= (event.global_position - last_mouse_position) / Global.camera_zoom
				last_mouse_position = event.global_position

func _zoom_to_mouse(direction: int) -> void:
	var old_zoom = Global.camera_zoom
	
	if direction < 0:
		%Camera.zoom /= zoom_speed
		Global.camera_zoom /= 1.1
	else:
		%Camera.zoom *= zoom_speed
		Global.camera_zoom *= 1.1
		
	var old_offset: Vector2 = %Camera.get_global_mouse_position() - %Camera.global_position
	var new_offset: Vector2 = old_offset * old_zoom / Global.camera_zoom
	%Camera.global_position += old_offset - new_offset
