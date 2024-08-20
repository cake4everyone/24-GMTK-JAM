extends CanvasLayer

@onready var OptionsLayer = get_node("../Options_Layer")

func _process(_delta):
	$Success/Fanfare.volume_db = SceneManager.volumeSFX
	if(!$Success.visible):
		if Input.is_action_just_pressed("ui_cancel") && !visible:
			show()
			get_node("..").set_process_mode(Node.PROCESS_MODE_DISABLED)
		elif Input.is_action_just_pressed("ui_cancel") && visible && !OptionsLayer.visible:
			hide()
			get_node("..").set_process_mode(Node.PROCESS_MODE_ALWAYS)
		elif Input.is_action_just_pressed("ui_cancel") && visible && OptionsLayer.visible:
			OptionsLayer.hide()

func _on_resume_pressed():
	hide()
	get_node("..").set_process_mode(Node.PROCESS_MODE_ALWAYS)

func _on_options_pressed():
	OptionsLayer.show()

func _on_quit_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_restart_level_pressed():
	SceneManager.load_lvl(SceneManager.currentWorld, SceneManager.currentLvl)
	
func lvl_completed():
	get_node("..").set_process_mode(Node.PROCESS_MODE_DISABLED)
	$Success/Fanfare.play()
	if SceneManager.currentLvl == 4 && SceneManager.currentWorld == 0:
		$Success/Panel/Label.text = "TUTORIAL COMPLETE\nWELL DONE!"
	if SceneManager.currentLvl == 3 && SceneManager.currentWorld == 3:
		$Success/Panel/Resume.hide()
		$Success/Panel/Label.text = "GAME COMPLETE\n\nThanks for Playing\n<3"

	$Panel.hide()
	$Success.show()


func _on_next_lvl_pressed():
	SceneManager.next_lvl()
