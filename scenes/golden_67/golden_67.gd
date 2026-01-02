extends Node2D

@onready var jumpscare: AudioStreamPlayer = $Jumpscare

func _ready() -> void:
	if !jumpscare.playing:
		jumpscare.play()

func _on_jumpscare_finished() -> void:
	SceneManager.to_office()
