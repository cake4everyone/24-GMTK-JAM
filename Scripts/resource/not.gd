extends LogicGate
class_name NOT

@export var input: LogicGate

func ready():
	input.activate.connect(on_input_activate)
	input.deactivate.connect(on_input_deactivate)

func default_state() -> bool:
	return !input.default_state()

func parse_node(node: Node):
	ready()
	input.parse_node(node)

func on_input_activate() -> void:
	deactivate.emit()

func on_input_deactivate() -> void:
	activate.emit()
