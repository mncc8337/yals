extends IC

func _ready() -> void:
	add_pin("O", PinType.OUTPUT)
	add_pin("I", PinType.INPUT)

func update_output() -> void:
	io_pin[PinType.OUTPUT][0].value = not io_pin[PinType.INPUT][0].value
