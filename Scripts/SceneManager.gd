extends Node

var LvlArr = [["tutorial_1", "tutorial_2", "tutorial_3"], 
["lvl_1", "lvl_2", "lvl_3", "lvl_4", "lvl_5", "lvl_6"],
["lvl_7", "lvl_8", "lvl_9", "lvl_10", "lvl_11", "lvl_12"],
["lvl_13", "lvl_14", "lvl_15", "lvl_16", "lvl_17", "lvl_18"]]

var currentWorld := 0
var currentLvl := 0

var volumeMusic := 0
var volumeSFX := 0
var lastSoundValues := [50,50]
var fullscreen := false
var music_pos

func next_lvl():
	if(currentLvl == 6):
		currentWorld += 1
		currentLvl = 1
		get_tree().change_scene_to_file(str("res://Scenes/lvl/"+ LvlArr[currentWorld][currentLvl - 1] + ".tscn"))
	else:
		currentLvl += 1
		get_tree().change_scene_to_file(str("res://Scenes/lvl/"+ LvlArr[currentWorld][currentLvl - 1] + ".tscn"))
