extends StaticBody2D
class_name Door

@export var gate: LogicGate

var door_collision_layer: int = self.collision_layer
var open: bool

func _ready():
	if gate:
		open = gate.default_state()
		gate.activate.connect(on_input_activate)
		gate.deactivate.connect(on_input_deactivate)
		gate.parse_node(self)
	else:
		open = false

func _process(_delta):
	if open:
		$Sprite2D.frame = 1
		self.collision_layer = 0
	else:
		$Sprite2D.frame = 0
		self.collision_layer = door_collision_layer

func on_input_activate():
	open = true
func on_input_deactivate():
	open = false
