extends LogicGate
class_name AND

@export var inputs: Array[LogicGate]

var state: Array[bool] = []

func ready():
	print("am i ready?")
	for i in range(inputs.size()):
		state.append(inputs[i].default_state())
		inputs[i].activate.connect(on_input_activate.bind(i))
		print("AND: connected %d (%s): %s" % [inputs[i], inputs[i].activate.get_connections()])
		inputs[i].deactivate.connect(on_input_deactivate.bind(i))

func default_state() -> bool:
	for input in inputs:
		if !input.default_state(): return false
	return true

func parse_node(node: Node):
	ready()
	for input in inputs:
		input.parse_node(node)

func on_input_activate(i: int) -> void:
	var before: bool = current_state()
	state[i] = true
	print("AND: activate %d (%s > %s)" % [i, before, current_state()])
	if !before && current_state():
		activate.emit()

func on_input_deactivate(i: int) -> void:
	var before: bool = current_state()
	state[i] = false
	if before:
		deactivate.emit()

func current_state() -> bool:
	for s in state:
		if !s: return false
	return true
