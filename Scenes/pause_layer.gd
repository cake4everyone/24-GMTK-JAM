extends CanvasLayer

@onready var OptionsLayer = get_node("../Options_Layer")

func _process(_delta):
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
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
