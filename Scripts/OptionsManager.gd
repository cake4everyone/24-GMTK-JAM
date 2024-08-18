extends CanvasLayer

func _process(delta):
	if(visible && Input.is_action_just_pressed("ui_cancel")):
		hide()


func _on_done_pressed():
	hide()
