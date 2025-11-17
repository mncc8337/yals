extends IC

@export var input_count: int = 2

func _ready() -> void:
	add_pin("O", false, PinType.OUTPUT)
	for i in range(input_count):
		add_pin("I" + str(i), false, PinType.INPUT)

func update_output() -> void:
	var res: bool = true
	for i in range(input_count):
		res = res and io_pin[PinType.INPUT][i].value
	io_pin[PinType.OUTPUT][0].value = res
