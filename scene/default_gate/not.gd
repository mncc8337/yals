extends IC

func _ready() -> void:
	add_pin("O", PinType.Output)
	add_pin("I", PinType.Input)

func update_output() -> void:
	io_pin[PinType.Output][0].value = not io_pin[PinType.Input][0].value
