extends CanvasLayer

func _on_cancel_pressed():
	hide()
	$TabContainer.current_tab = 0
