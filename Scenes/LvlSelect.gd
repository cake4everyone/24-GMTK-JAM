extends CanvasLayer

func _on_cancel_pressed():
	hide()
	$TabContainer.current_tab = 0


func _on_tutorial_1_pressed():
	SceneManager.load_lvl(0,1)

func _on_tutorial_2_pressed():
	SceneManager.load_lvl(0,2)


func _on_tutorial_3_pressed():
	SceneManager.load_lvl(0,3)


func _on_1_1_pressed():
	SceneManager.load_lvl(1,1)


func _on_1_2_pressed():
	SceneManager.load_lvl(1,2)


func _on_1_3_pressed():
	SceneManager.load_lvl(1,3)


func _on_1_4_pressed():
	SceneManager.load_lvl(1,4)


func _on_1_5_pressed():
	SceneManager.load_lvl(1,5)


func _on_1_6_pressed():
	SceneManager.load_lvl(1,6)


func _on_2_1_pressed():
	SceneManager.load_lvl(2,1)


func _on_2_2_pressed():
	SceneManager.load_lvl(2,2)


func _on_2_3_pressed():
	SceneManager.load_lvl(2,3)
	
func _on_2_4_pressed():
	SceneManager.load_lvl(2,4)
