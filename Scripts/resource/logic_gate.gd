extends Resource
class_name LogicGate

signal activate
signal deactivate

func default_state() -> bool:
	assert(false, "\"default_state()\" on class LogicGate cannot be called directly. Create another logic gate instead!")
	return false

func parse_node(_node: Node):
	pass
