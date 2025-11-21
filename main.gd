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
	%IC.add_pin("O", IC.PinType.OUTPUT)
