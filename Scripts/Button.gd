extends LogicInput
class_name PushButton

## If [true] the button will stay pressed when the activator leaves the trigger area.
## 
## If [false] the button wiil pop back out to be activated again.
@export var stay_pressed: bool = true
## Time in seconds that the button will stay pressed after releasing it.

## Has no effect if [stay_pressed] is [true].
@export var release_time: float = 0.5

var is_pressed := false

func _on_area_2d_body_entered(body):
	check_press(body)

func _on_area_2d_body_exited(__: Node2D):
	check_release()

func _on_area_2d_area_entered(area):
	check_press(area)

func _on_area_2d_area_exited(__: Area2D):
	check_release()

func check_press(node: Node2D):
	if !is_pressed && is_activator(node):
		press()

func check_release():
	if !is_pressed || stay_pressed || has_activator():
		return

	await get_tree().create_timer(release_time).timeout
	if is_pressed: release()

func press():
	is_pressed = true
	$Sprite2D.frame = 1
	activate.emit()
func release():
	is_pressed = false
	$Sprite2D.frame = 0
	deactivate.emit()

func is_activator(node: Node2D) -> bool:
	return node && (node is Player || node.get_parent() is Platform)

func has_activator() -> bool:
	for body in $Area2D.get_overlapping_bodies():
		if is_activator(body):
			return true
	for area in $Area2D.get_overlapping_areas():
		if is_activator(area):
			return true
	return false
