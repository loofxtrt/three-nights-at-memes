extends Area2D

@onready var honk_audio: AudioStreamPlayer = $"../HonkAudio"

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			honk_audio.play()
