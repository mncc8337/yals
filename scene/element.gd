class_name Element
extends Node2D


signal mouse_entered
signal mouse_exited

var draggable: bool = true
var is_dragging: bool = false


func _on_area_mouse_exited() -> void:
	mouse_exited.emit()
