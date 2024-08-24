extends Node2D
class_name Goal

signal LvlComplete

@export var gate: LogicGate

var enabled: bool

func _ready():
	if gate:
		enabled = gate.default_state()
		gate.activate.connect(on_input_activate)
		gate.deactivate.connect(on_input_deactivate)
		gate.parse_node(self)
	else:
		enabled = true

func _process(_delta):
	if enabled:
		$Flag.frame = 1
	else:
		$Flag.frame = 0

func _physics_process(_delta):
	if enabled && %Player in $Area2D.get_overlapping_bodies():
		%PauseLayer.lvl_completed()
		
func on_input_activate():
	enabled = true
func on_input_deactivate():
	enabled = false
