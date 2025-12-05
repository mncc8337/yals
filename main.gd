extends Node


@onready var ic_scene: Resource = preload("res://scene/elements/ic.tscn")
@onready var and_scene: Resource = preload("res://scene/default_gate/and.tscn")
@onready var or_scene: Resource = preload("res://scene/default_gate/or.tscn")
@onready var xor_scene: Resource = preload("res://scene/default_gate/xor.tscn")
@onready var not_scene: Resource = preload("res://scene/default_gate/not.tscn")

var main_ic: IC


func _ready() -> void:
	main_ic = ic_scene.instantiate()
	main_ic.design_mode = true
	add_child(main_ic)
	Global.current_ic = main_ic
	
	add_pin("I", IC.PinType.Input)
	add_ic(not_scene)
	add_ic(and_scene)
	add_ic(or_scene)


func add_pin(pin_name: String, pin_type: IC.PinType):
	%Elements.add_child(main_ic.add_pin(pin_name, pin_type))


func add_ic(scene: Resource):
	var ic = scene.instantiate()
	main_ic.add_element(ic)
	%Elements.add_child(ic)


func _on_timer_timeout() -> void:
	Global.current_ic.update_output(Global.signal_propagating_queue)
