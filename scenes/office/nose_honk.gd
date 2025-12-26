extends Area2D

@onready var nose_honk_sfx: AudioStreamPlayer = $"../NoseHonkSFX"
@onready var tung_tung_sfx: AudioStreamPlayer = $"../TungTungSFX"

func _on_labubu_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			nose_honk_sfx.play()

func _on_tung_tung_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			tung_tung_sfx.play()
