extends Node


@onready var joint_scene: Resource = preload("res://scene/joint.tscn")
@onready var wire_scene: Resource = preload("res://scene/wire.tscn")

var current_drawing: Wire = null
var is_drawing: bool = false


func _unhandled_input(event: InputEvent) -> void:
	if Global.current_mode != Global.Mode.Drawing:
		if current_drawing:
			%Elements.remove_child(current_drawing)
			current_drawing = null
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if current_drawing:
					if Global.selecting_element is Joint:
						current_drawing.add_joint(Global.selecting_element)
						current_drawing = null
					else:
						var new_joint: Joint = joint_scene.instantiate()
						%Elements.add_child(new_joint)
						new_joint.draggable = true
						new_joint.show_label = false
						new_joint.name = str(new_joint.get_instance_id())
						new_joint.value = false
						new_joint.associated_ic = null
						new_joint.label_placement = Joint.LabelPlacement.Up
						new_joint.global_position = %Camera.get_global_mouse_position()
						current_drawing.add_joint(new_joint)
						_generate_wire(new_joint)
						print("added new wire")
				else:
					if Global.selecting_element is Joint:
						_generate_wire(Global.selecting_element)
	elif event is InputEventMouseMotion:
		if current_drawing:
			current_drawing.set_end_position(%Camera.get_global_mouse_position())


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if Global.current_mode == Global.Mode.Drawing:
			Global.current_mode = Global.Mode.Normal
			print("current mode is normal")
		elif Global.current_mode == Global.Mode.Normal:
			Global.current_mode = Global.Mode.Drawing
			print("current mode is drawing")


func _generate_wire(joint: Joint) -> void:
	current_drawing = wire_scene.instantiate()
	%Elements.add_child(current_drawing)
	current_drawing.add_joint(joint)
