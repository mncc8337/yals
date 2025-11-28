extends IC

@export var input_count: int = 2

func _ready() -> void:
	add_pin("O", PinType.Output)
	for i in range(input_count):
		add_pin("I" + str(i), PinType.Input)

func update_output() -> void:
	var res: bool = false
	for i in range(input_count):
		if io_pin[PinType.Input][i].value:
			res = true
			break

	io_pin[PinType.Output][0].value = res
