extends CanvasLayer

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		$CreditsLayer.hide()
		$OptionsLayer.hide()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_options_pressed():
	$OptionsLayer.show()

func _on_credits_pressed():
	$CreditsLayer.show()

func _on_quit_pressed():
	get_tree().quit()

func _on_done_credits_pressed():
	$CreditsLayer.hide()
