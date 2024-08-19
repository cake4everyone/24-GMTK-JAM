extends Node2D
class_name Goal

@export var input: LogicInput

var enabled: bool = true

func _ready():
	if input:
		enabled = false
		input.activate.connect(on_input_activate)
		input.deactivate.connect(on_input_deactivate)

func _process(_delta):
	if enabled:
		$Flag.frame = 1
	else:
		$Flag.frame = 0

func _physics_process(_delta):
	if %Player in $Area2D.get_overlapping_bodies():
		pass

func on_input_activate():
	enabled = true
func on_input_deactivate():
	enabled = false
