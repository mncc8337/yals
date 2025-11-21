class_name Element
extends Node2D


var is_dragging: bool = false


func _on_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print(event)
