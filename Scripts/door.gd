extends StaticBody2D
class_name Door

@export var input: LogicInput

var door_collision_layer: int = self.collision_layer

func _ready():
	if input:
		input.activate.connect(on_input_activate)
		input.deactivate.connect(on_input_deactivate)

func on_input_activate():
	$Sprite2D.frame = 1
	self.collision_layer = 0
func on_input_deactivate():
	$Sprite2D.frame = 0
	self.collision_layer = door_collision_layer
