extends LogicGate
class_name NodeBuffer

@export_node_path("LogicInput") var input: NodePath

var input_node: LogicInput

# @override
func default_state() -> bool:
	return false

func parse_node(node: Node):
	input_node = node.get_node(input) as LogicInput
	input_node.activate.connect(on_input_activate)
	input_node.deactivate.connect(on_input_deactivate)

func on_input_activate() -> void:
	print("node buffer: activate %s" % [activate.get_connections()])
	activate.emit()

func on_input_deactivate() -> void:
	print("node buffer: deactivate")
	deactivate.emit()
