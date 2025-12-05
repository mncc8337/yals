extends IC

func _ready() -> void:
	super()
	add_pin("O", PinType.Output)
	add_pin("I", PinType.Input)
	set_pin("O", true)

func update_output(_signal_propagating_queue: Array[Joint]) -> void:
	io_pin[PinType.Output][0].value = not io_pin[PinType.Input][0].value
