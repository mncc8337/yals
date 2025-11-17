extends Node

@onready var and_scene: Resource = preload("res://scene/default_gate/and.tscn")
@onready var or_scene: Resource = preload("res://scene/default_gate/or.tscn")
@onready var xor_scene: Resource = preload("res://scene/default_gate/xor.tscn")
@onready var not_scene: Resource = preload("res://scene/default_gate/not.tscn")

func _ready() -> void:
	var ic: IC = mux_2_1()
	
	ic.set_pin("A", false)
	ic.set_pin("B", true)
	
	ic.set_pin("S", false)
	ic.update_output()
	print(ic.get_pin("O").value)
	print()
	
	ic.set_pin("S", true)
	ic.update_output()
	print(ic.get_pin("O").value)
	print()

func mux_2_1() -> IC:
	var ic: IC = IC.new()
	ic.name = "MUX-2-1"
	
	var a = ic.add_pin("A", false, IC.PinType.INPUT)
	var b = ic.add_pin("B", false, IC.PinType.INPUT)
	var s = ic.add_pin("S", false, IC.PinType.INPUT)
	var o = ic.add_pin("O", false, IC.PinType.OUTPUT)
	
	var AND0 = and_scene.instantiate() as IC
	var AND1 = and_scene.instantiate() as IC
	var NOT = not_scene.instantiate() as IC
	var OR = or_scene.instantiate() as IC
	add_child(AND0)
	add_child(AND1)
	add_child(NOT)
	add_child(OR)
	ic.add_element(AND0)
	ic.add_element(AND1)
	ic.add_element(NOT)
	ic.add_element(OR)
	
	a.make_connection(AND0.get_pin("I0"))
	b.make_connection(AND1.get_pin("I0"))
	s.make_connection(NOT.get_pin("I"))
	
	NOT.get_pin("O").make_connection(AND0.get_pin("I1"))
	s.make_connection(AND1.get_pin("I1"))
	
	AND0.get_pin("O").make_connection(OR.get_pin("I0"))
	AND1.get_pin("O").make_connection(OR.get_pin("I1"))
	
	o.make_connection(OR.get_pin("O"))
	
	ic.make_graph()
	return ic

func half_adder() -> IC:
	var ic: IC = IC.new()
	ic.name = "HA"
	
	var bit0 = ic.add_pin("BIT0", false, IC.PinType.INPUT)
	var bit1 = ic.add_pin("BIT1", false, IC.PinType.INPUT)
	var sum = ic.add_pin("SUM", false, IC.PinType.OUTPUT)
	var carry = ic.add_pin("CARRY", false, IC.PinType.OUTPUT)
	
	var AND = and_scene.instantiate() as IC
	var XOR = xor_scene.instantiate() as IC
	add_child(AND)
	add_child(XOR)
	ic.add_element(AND)
	ic.add_element(XOR)
	
	bit0.make_connection(AND.io_pin[IC.PinType.INPUT][0])
	bit1.make_connection(AND.io_pin[IC.PinType.INPUT][1])
	
	bit0.make_connection(XOR.io_pin[IC.PinType.INPUT][0])
	bit1.make_connection(XOR.io_pin[IC.PinType.INPUT][1])
	
	sum.make_connection(XOR.io_pin[IC.PinType.OUTPUT][0])
	carry.make_connection(AND.io_pin[IC.PinType.OUTPUT][0])
	
	ic.make_graph()
	return ic

func full_adder() -> IC:
	var ic = IC.new()
	ic.name = "FA"
	
	var bit0 = ic.add_pin("BIT0", false, IC.PinType.INPUT)
	var bit1 = ic.add_pin("BIT1", false, IC.PinType.INPUT)
	var bit2 = ic.add_pin("BIT2", false, IC.PinType.INPUT)
	var sum = ic.add_pin("SUM", false, IC.PinType.OUTPUT)
	var carry = ic.add_pin("CARRY", false, IC.PinType.OUTPUT)
	
	var h0 = half_adder()
	var h1 = half_adder()
	h0.name = "HA0" + str(h0.get_instance_id())
	h1.name = "HA1" + str(h1.get_instance_id())
	h0.make_graph()
	h1.make_graph()
	ic.add_element(h0)
	ic.add_element(h1)
	
	var OR = or_scene.instantiate() as IC
	add_child(OR)
	ic.add_element(OR)

	bit0.make_connection(h0.get_pin("BIT0"))
	bit1.make_connection(h0.get_pin("BIT1"))
	bit2.make_connection(h1.get_pin("BIT0"))
	h1.get_pin("BIT1").make_connection(h0.get_pin("SUM"))
	
	h0.get_pin("CARRY").make_connection(OR.io_pin[IC.PinType.INPUT][0])
	h1.get_pin("CARRY").make_connection(OR.io_pin[IC.PinType.INPUT][1])
	
	OR.io_pin[IC.PinType.OUTPUT][0].make_connection(carry)
	h1.get_pin("SUM").make_connection(sum)
	
	ic.make_graph()
	return ic
