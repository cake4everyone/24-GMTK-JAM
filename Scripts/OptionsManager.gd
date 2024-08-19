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
	if value == 0:
		SceneManager.volumeMusic = -80
	elif value < 50:
		SceneManager.volumeMusic = -(50 - value) / 2 
	elif value > 50:
		SceneManager.volumeMusic = abs((50 - value) / 2)
			
	SceneManager.lastSoundValues[0] = value
	

func _on_SFX_value_changed(value):
	$Panel/SFXL/Count.text = str(value)
	SceneManager.volumeMusic = value
	if(value == 0):
		SceneManager.volumeSFX = -80
	else:
		SceneManager.volumeSFX = value/5 - 10
	SceneManager.lastSoundValues[1] = value

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
