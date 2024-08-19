extends Node2D
class_name PushButton

signal activate

var is_pressed := false

func _on_area_2d_body_entered(body):
	if body is Player:
		press()


func _on_area_2d_area_entered(area):
	if area.get_parent() is Platform:
		press()

func press():
	is_pressed = true
	$Sprite2D.frame = 1
	activate.emit()
