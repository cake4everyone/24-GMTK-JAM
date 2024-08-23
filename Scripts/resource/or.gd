extends LogicGate
class_name OR

@export var inputs: Array[LogicGate]

var state: Array[bool] = []

func ready():
	for i in range(inputs.size()):
		state.append(inputs[i].default_state())
		inputs[i].activate.connect(on_input_activate.bind(i))
		inputs[i].deactivate.connect(on_input_deactivate.bind(i))

func default_state() -> bool:
	for input in inputs:
		if input.default_state(): return true
	return false

func parse_node(node: Node):
	ready()
	for input in inputs:
		input.parse_node(node)

func on_input_activate(i: int) -> void:
	var before: bool = current_state()
	state[i] = true
	if !before:
		activate.emit()
	
func on_input_deactivate(i: int) -> void:
	var before: bool = current_state()
	state[i] = false
	if before && !current_state():
		deactivate.emit()

func current_state() -> bool:
	for s in state:
		if s: return true
	return false
