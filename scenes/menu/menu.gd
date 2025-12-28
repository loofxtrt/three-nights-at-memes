extends Control

@onready var play: Button = $PlayVBox/Play
@onready var night_label: Label = $PlayVBox/NightLabel
@onready var success: AudioStreamPlayer = $Success
@onready var extras_container: Control = $ExtrasContainer
@onready var extra_content_sprite: AnimatedSprite2D = $ExtrasContainer/ExtraContent

const HOLD_TIME = 2
var holding: float = 0.0
var already_triggered: bool = false

var current_extras_frame = 0

func update_play():
	var night = Progress.load_progress()
	night_label.text = "noite " + str(night)

func _ready() -> void:
	update_play()
	extras_container.visible = false

func _process(delta: float) -> void:
	if Input.is_action_pressed("delete_progress"):
		holding += delta
		
		if holding >= HOLD_TIME && !already_triggered:
			# deletar o progresso depois de x segundos pressionando o input
			Progress.delete_progress()
			already_triggered = true
			
			# atualizar o texto do botão de play e tocar uma notificação
			update_play()
			if !success.playing:
				success.play()
			
			holding = 0
	else:
		holding = 0
		already_triggered = false

func _input(event: InputEvent) -> void:
	if !extras_container.visible:
		return
	
	var total_frames = extra_content_sprite.sprite_frames.get_frame_count("default")
	var last_index = total_frames - 1 # último frame 
	
	# carrossel infinito
	if event.is_action_pressed("arrow_left"):
		if current_extras_frame < 0:
			current_extras_frame = last_index
		else:
			current_extras_frame -= 1
	elif event.is_action_pressed("arrow_right"):
		if current_extras_frame > total_frames:
			current_extras_frame = 0
		else:
			current_extras_frame += 1
	
	# atualizar o frame pra corresponder com o índice atual
	extra_content_sprite.frame = current_extras_frame

func _on_play_pressed() -> void:
	# ir pro escritório
	var office = load("uid://diw1qplhntkkf")
	get_tree().change_scene_to_packed(office)

func _on_extras_pressed() -> void:
	extras_container.visible = !extras_container.visible
