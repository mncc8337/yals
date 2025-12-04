extends IC

@export var input_count: int = 2

func _ready() -> void:
	super()
	add_pin("O", PinType.Output)
	for i in range(input_count):
		add_pin("I" + str(i), PinType.Input)

func update_output(_signal_propagating_queue: Array[Joint]) -> void:
	var res: bool = io_pin[PinType.Input][0].value
	for i in range(1, input_count):
		res = (res != io_pin[PinType.Input][i].value)

	io_pin[PinType.Output][0].value = res
