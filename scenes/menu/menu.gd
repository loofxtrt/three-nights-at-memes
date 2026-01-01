extends Control

@onready var play: Button = $PlayVBox/Play
@onready var night_label: Label = $PlayVBox/NightLabel
@onready var success: AudioStreamPlayer = $Success
@onready var extras_container: Control = $ExtrasContainer
@onready var extra_content_sprite: AnimatedSprite2D = $ExtrasContainer/ExtraContent
@onready var custom_night_container: VBoxContainer = $CustomNightContainer

const CHANNEL_BUTTON = preload("uid://3idyt7myk8tf")

const HOLD_TIME = 2
var holding: float = 0.0
var already_triggered: bool = false

var current_extras_frame = 0
var custom_night_inputs = []

func update_play():
	var night = Progress.load_progress()
	night_label.text = "noite " + str(night)

func _ready() -> void:
	update_play()
	extras_container.visible = false
	custom_night_container.visible = false
	make_custom_night_inputs()

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

func make_custom_night_inputs():
	var inputs = []
	
	for field in ["luva_ai", "bill_ai", "virginia_ai", "amostradinho_ai"]:
		var input_container = HBoxContainer.new()
		
		var label = Label.new()
		label.text = field
		label.theme = CHANNEL_BUTTON
		
		var spin_box = SpinBox.new()
		spin_box.max_value = 20
		spin_box.min_value = 0
		spin_box.step = 1 # pra ser sempre int
		spin_box.rounded = true
		spin_box.theme = CHANNEL_BUTTON
		
		input_container.add_child(label)
		input_container.add_child(spin_box)
		
		custom_night_container.add_child(input_container)
		inputs.append(input_container)
	
	custom_night_inputs = inputs

func _on_play_pressed() -> void:
	# ir pro jornal se for pra primeira noite
	# ou ir direto pro escritório caso seja outra
	var night = Progress.load_progress()
	
	if night == 1:
		SceneManager.to_newspaper()
	else:
		SceneManager.to_office()

func _on_extras_pressed() -> void:
	extras_container.visible = !extras_container.visible

func _on_custom_nillth_pressed() -> void:
	custom_night_container.visible = !custom_night_container.visible

func _on_apply_pressed() -> void:
	var ai_map = {
		"luva_ai": 0,
		"bill_ai": 0,
		"virginia_ai": 0,
		"amostradinho_ai": 0
	}
	
	for input in custom_night_inputs:
		var label_text
		var spin_box_value
		
		var children = input.get_children()
		for c in children:
			if c is Label:
				label_text = c.text
			if c is SpinBox:
				spin_box_value = c.value
			
		if !ai_map.has(label_text):
			continue
		ai_map[label_text] = spin_box_value
	
	CustomNight.ai_map = ai_map
	SceneManager.to_office()
