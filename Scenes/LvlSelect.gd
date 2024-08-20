extends CanvasLayer

func _on_cancel_pressed():
	hide()
	$TabContainer.current_tab = 0

func on_level_selected(world: int, lvl: int):
	SceneManager.load_lvl(world, lvl)
