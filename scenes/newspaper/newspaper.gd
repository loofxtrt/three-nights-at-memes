extends Node2D

@onready var heartbeat: AudioStreamPlayer = $Heartbeat

func _ready() -> void:
	heartbeat.play()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next"):
		SceneManager.to_office()
