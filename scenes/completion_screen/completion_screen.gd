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
	# subtrai 1 pq a ordem em que as noites são salvas tem uma lógica que faz elas serem
	# incrementadas logo após a vitória
	var night = Progress.load_progress()
	night -= 1

	if night > 3:
		print("fim")
		SceneManager.to_menu()
		return

	# redirecionar de volta pro escritório ou pra um minigame quando a tela de 6 am acaba
	match night:
		3:
			SceneManager.to_minigame_02()
		2:
			SceneManager.to_minigame_01()
		1:
			SceneManager.to_menu()
		_:
			# valor default
			SceneManager.to_menu()

func set_hour_text(text: String):
	hour.text = text
