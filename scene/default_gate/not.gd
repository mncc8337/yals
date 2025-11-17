extends IC

func _ready() -> void:
	add_pin("O", false, PinType.OUTPUT)
	add_pin("I", false, PinType.INPUT)

func update_output() -> void:
	io_pin[PinType.OUTPUT][0].value = not io_pin[PinType.INPUT][0].value
