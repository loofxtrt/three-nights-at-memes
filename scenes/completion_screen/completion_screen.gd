extends Node2D

@onready var music: AudioStreamPlayer = $Music
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hour: Label = $Hour

func _ready() -> void:
	music.play()
	animation_player.play("wiggle")

func _on_music_finished() -> void:
	pass # Replace with function body.

func set_hour_text(text: String):
	hour.text = text
