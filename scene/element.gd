class_name Element
extends Node2D


var draggable: bool = true

var is_dragging: bool = false
var mouse_relative_distance: Vector2

# handles dragging
func _input(event: InputEvent) -> void:
	if not draggable:
		return
	if event is InputEventMouseMotion and is_dragging:
		self.global_position = event.position + mouse_relative_distance


# detects drag/click events
func _on_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed:
				if not is_dragging:
					print("clicked ", self)
				else:
					is_dragging = false
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			if not is_dragging:
				is_dragging = true
				mouse_relative_distance = self.global_position - event.global_position
				print("dragging ", self)
