@tool
extends Node


@onready var and_scene: Resource = preload("res://scene/default_gate/and.tscn")
@onready var or_scene: Resource = preload("res://scene/default_gate/or.tscn")
@onready var xor_scene: Resource = preload("res://scene/default_gate/xor.tscn")
@onready var not_scene: Resource = preload("res://scene/default_gate/not.tscn")

func _ready() -> void:
	%IC.add_pin("I0", IC.PinType.INPUT)
	%IC.add_pin("I1", IC.PinType.INPUT)
	%IC.add_pin("I2", IC.PinType.INPUT)
	%IC.add_pin("I3", IC.PinType.INPUT)
	%IC.add_pin("I4", IC.PinType.INPUT)
	%IC.add_pin("I5", IC.PinType.INPUT)
	%IC.add_pin("I7", IC.PinType.INPUT)
	%IC.add_pin("I8", IC.PinType.INPUT)
	%IC.add_pin("I9", IC.PinType.INPUT)
	%IC.add_pin("I10", IC.PinType.INPUT)
	%IC.add_pin("I11", IC.PinType.INPUT)
	%IC.add_pin("O1", IC.PinType.OUTPUT)
	%IC.add_pin("O2", IC.PinType.OUTPUT)
	%IC.add_pin("O3", IC.PinType.OUTPUT)
	%IC.add_pin("O4", IC.PinType.OUTPUT)
