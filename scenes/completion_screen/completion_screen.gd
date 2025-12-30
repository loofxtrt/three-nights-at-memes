extends Node2D

@onready var music: AudioStreamPlayer = $Music
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hour: Label = $Hour

# não funciona com preload
#const OFFICE: PackedScene = preload("res://scenes/office/office.tscn")

func _ready() -> void:
	music.play()
	animation_player.play("wiggle")

func _on_music_finished() -> void:
	var night = Progress.load_progress()

	if night > 3:
		print("fim")
		return

	# redirecionar de volta pro escritório ou pra um minigame quando a tela de 6 am acaba
	match night:
		3:
			SceneManager.to_minigame_02()
		2:
			SceneManager.to_minigame_01()
		1:
			SceneManager.to_office()
		_:
			# valor default
			SceneManager.to_office()

func set_hour_text(text: String):
	hour.text = text
