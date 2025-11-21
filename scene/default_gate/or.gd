extends IC

@export var input_count: int = 2

func _ready() -> void:
	add_pin("O", PinType.OUTPUT)
	for i in range(input_count):
		add_pin("I" + str(i), PinType.INPUT)

func update_output() -> void:
	var res: bool = false
	for i in range(input_count):
		if io_pin[PinType.INPUT][i].value:
			res = true
			break

	io_pin[PinType.OUTPUT][0].value = res
