extends CanvasLayer

func _ready():
	$Panel/MusicL/HSlider.value = SceneManager.volumeMusic
	$Panel/SFXL/HSlider.value = SceneManager.volumeMusic
	$Panel/FullscreenL/FullscreenCheck.button_pressed = SceneManager.fullscreen

func _process(_delta):
	if visible && Input.is_action_just_pressed("ui_cancel"):
		hide()

func _on_done_pressed():
	hide()

func _on_music_value_changed(value):
	$Panel/MusicL/Count.text = str(value)
	SceneManager.volumeMusic = value

func _on_SFX_value_changed(value):
	$Panel/SFXL/Count.text = str(value)
	SceneManager.volumeMusic = value

func _on_fullscreen_check_toggled(toggled_on):
	SceneManager.fullscreen = toggled_on
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
