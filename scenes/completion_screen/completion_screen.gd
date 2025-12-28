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
	if night < 3:
		# redirecionar de volta pro escritório quando a tela de 6 am acaba
		var office = load("uid://diw1qplhntkkf") # funciona com load
		get_tree().change_scene_to_packed(office)
	else:
		print("fim")

func set_hour_text(text: String):
	hour.text = text
