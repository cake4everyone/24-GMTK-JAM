extends Node

var LvlArr = [["tutorial_1", "tutorial_2", "tutorial_3", "tutorial_4"], 
["lvl_1", "lvl_2", "lvl_3", "lvl_4", "lvl_5", "lvl_6"],
["lvl_7", "lvl_8", "lvl_9", "lvl_10", "lvl_11", "lvl_12"],
["lvl_13", "lvl_14", "lvl_15"]]

var currentWorld := 0
var currentLvl := 0

var volumeMusic := 0
var volumeSFX := 0
var lastSoundValues := [30, 30]
var fullscreen := false
var music_pos

func _ready():
	update_music_volume()
	update_sfx_volume()

func next_lvl():
	if((currentWorld == 1 || currentWorld == 2) && currentLvl == 6):
		currentWorld += 1
		currentLvl = 1
		get_tree().change_scene_to_file(str("res://Scenes/lvl/"+ LvlArr[currentWorld][currentLvl - 1] + ".tscn"))
	elif(currentWorld == 0 && currentLvl == 4):
		currentWorld += 1
		currentLvl = 1
		get_tree().change_scene_to_file(str("res://Scenes/lvl/"+ LvlArr[currentWorld][currentLvl - 1] + ".tscn"))
	elif(currentWorld == 3 && currentLvl == 3):
		#thx for playing
		pass
	else:
		currentLvl += 1
		get_tree().change_scene_to_file(str("res://Scenes/lvl/"+ LvlArr[currentWorld][currentLvl - 1] + ".tscn"))

func load_lvl(world, lvl):
	currentWorld = world
	currentLvl = lvl
	get_tree().change_scene_to_file(str("res://Scenes/lvl/"+ LvlArr[world][lvl - 1] + ".tscn"))

func update_music_volume():
	if lastSoundValues[0] == 0:
		volumeMusic = -80
	else:
		volumeMusic = -(50 - lastSoundValues[0]) / 2

func update_sfx_volume():
	if lastSoundValues[1] == 0:
		volumeSFX = -80
	else:
		volumeSFX = -(50 - lastSoundValues[1]) / 2
