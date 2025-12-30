extends Node

const MENU = preload("uid://cd6bwdxwxudq1")
const OFFICE = preload("uid://diw1qplhntkkf")
const COMPLETION_SCREEN = preload("uid://dah2e3e275agu")
const MINIGAME_01 = preload("uid://d2o3uuoqupeml")
const MINIGAME_02 = preload("uid://cvm7gcgjd82oa")

func _change_scene(constant: PackedScene):
	get_tree().change_scene_to_packed(constant)

func to_menu():
	_change_scene(MENU)

func to_completion_screen():
	_change_scene(COMPLETION_SCREEN)

func to_office():
	_change_scene(OFFICE)

func to_minigame_01():
	_change_scene(MINIGAME_01)

func to_minigame_02():
	_change_scene(MINIGAME_02)
