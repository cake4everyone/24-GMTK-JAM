extends Node2D
class_name Goal

func _process(_delta):
	if %Player in $Area2D.get_overlapping_bodies():
		pass
