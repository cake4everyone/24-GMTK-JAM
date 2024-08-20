extends CanvasLayer

func _ready():
	$Panel/FullscreenL/FullscreenCheck.button_pressed = SceneManager.fullscreen

func _process(_delta):
	if visible && Input.is_action_just_pressed("ui_cancel"):
		hide()
	$"BG-Music".volume_db = SceneManager.volumeMusic
	
	if !$"BG-Music".playing:
		$"BG-Music".play()

func _on_done_pressed():
	hide()

func _on_music_value_changed(value):
	$Panel/MusicL/Count.text = str(value)
	SceneManager.lastSoundValues[0] = value
	SceneManager.update_music_volume()
	

func _on_SFX_value_changed(value):
	$Panel/SFXL/Count.text = str(value)
	SceneManager.lastSoundValues[1] = value
	SceneManager.update_sfx_volume()

func _on_fullscreen_check_toggled(toggled_on):
	SceneManager.fullscreen = toggled_on
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_options_pressed():
	$Panel/MusicL/HSlider.value = SceneManager.lastSoundValues[0]
	$Panel/SFXL/HSlider.value = SceneManager.lastSoundValues[1]
	$Panel/MusicL/Count.text = str(SceneManager.lastSoundValues[0])
	$Panel/SFXL/Count.text = str(SceneManager.lastSoundValues[1])
