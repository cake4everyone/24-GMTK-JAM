extends CanvasLayer

func _ready():
	$Play.hide()
	$Lvls.hide()
	$Options.hide()
	$Credits.hide()
	$Quit.hide()
	await get_tree().create_timer(0.2).timeout
	$Play.show()
	await get_tree().create_timer(0.2).timeout
	$Lvls.show()
	await get_tree().create_timer(0.2).timeout
	$Options.show()
	await get_tree().create_timer(0.2).timeout
	$Credits.show()
	await get_tree().create_timer(0.2).timeout
	$Quit.show()
	

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		$CreditsLayer.hide()
		$OptionsLayer.hide()
		$LvlSelect.hide()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/lvl/lvl_1.tscn")

func _on_lvls_pressed():
	$LvlSelect.show()

func _on_options_pressed():
	$OptionsLayer.show()

func _on_credits_pressed():
	$CreditsLayer.show()

func _on_quit_pressed():
	get_tree().quit()

func _on_done_credits_pressed():
	$CreditsLayer.hide()

