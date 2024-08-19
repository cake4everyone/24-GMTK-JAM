extends Node2D

func _process(delt):
	if %Player in $Area2D.get_overlapping_bodies():
		pass
