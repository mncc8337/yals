extends Node

signal mode_changed(new_mode: Mode)
signal element_selected(element: Element)

enum Mode {
	Normal,
	Drawing,
}

var selecting_element: Element = null:
	set(val):
		if selecting_element != val:
			selecting_element = val
			element_selected.emit(selecting_element)

var current_mode: Mode = Mode.Normal:
	set(val):
		if current_mode != val:
			current_mode = val
			mode_changed.emit(current_mode)
