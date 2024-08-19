extends Node2D
class_name PushButton

var pressed := false

func _on_area_2d_body_entered(body):
	if body is Player:
		pressed = true
		$Sprite2D.frame = 1


func _on_area_2d_area_entered(area):
	if area.get_parent() is Platform:
		pressed = true
		$Sprite2D.frame = 1
