extends Node

signal mode_changed(new_mode: Mode)

enum Mode {
	Normal,
	Drawing,
}

var selected_elements: Array[Element] = []

var current_mode: Mode = Mode.Normal:
	set(val):
		if current_mode != val:
			current_mode = val
			mode_changed.emit(current_mode)


var camera_zoom: float = 1.0

var current_ic: IC = null
var signal_propagating_queue: Array[Joint] = []


func select_element(e: Element) -> void:
	selected_elements.append(e)
	e.selected.emit()


func deselect_element(e: Element) -> void:
	selected_elements.erase(e)
	e.deselected.emit()


func clear_selected_elements() -> void:
	for e in selected_elements:
		e.deselected.emit()
	selected_elements.clear()
