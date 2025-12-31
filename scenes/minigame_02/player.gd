extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite
@onready var heartbeat: AudioStreamPlayer = $"../DialogLayer/Heartbeat"
@onready var dialog_layer: CanvasLayer = $"../DialogLayer"
@onready var dialog_tip: Label = $"../DialogLayer/DialogTip"
@onready var dialog_text: Label = $"../DialogLayer/DialogText"
@onready var pickup: AudioStreamPlayer = $"../Pickup"

const SPEED = 300
var direction: Vector2

var has_picked_up_gasoline: bool = false
var has_started_fire: bool = false
var reading_dialog: bool = false
var next_dialog: Array = []

func _ready() -> void:
	dialog_text.text = "S. > essa é pelo meu casca de bala."
	show_dialog()

func _physics_process(delta: float) -> void:
	if reading_dialog:
		return
	
	direction.x = Input.get_axis("left", "right")
	direction.y = Input.get_axis("top", "down")
	
	direction = direction.normalized() # corrigir velocidade angular/diagonal
	
	if direction.x > 0: 
		sprite.flip_h = true
	elif direction.x < 0: # em vez de else pq se não toda vez que para de andar, flipa
		sprite.flip_h = false
	
	if direction:
		# andar
		velocity = direction * SPEED
	else:
		# parar de andar
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	
	move_and_slide()

func show_dialog():
	reading_dialog = true
	dialog_layer.visible = true

	if !heartbeat.playing:
		heartbeat.play()

func hide_dialog():
	heartbeat.stop()
	reading_dialog = false
	
	if dialog_text.text == "S. > acabou, gêmeo":
		dialog_tip.visible = false
		dialog_text.visible = false
		await get_tree().create_timer(1.5).timeout
		SceneManager.to_final_cutscene()
	
	dialog_layer.visible = false

func _input(event: InputEvent) -> void:
	if !reading_dialog:
		return
	
	if event.is_action_pressed("next"):
		if next_dialog.size() > 0:
			var text = next_dialog.pop_front() # remove o prímeiro índice e segue pro próximo
			dialog_text.text = text
		else:
			hide_dialog()

func pickup_gasoline():
	pickup.play()
	has_picked_up_gasoline = true

func start_final_dialog():
	if !has_picked_up_gasoline:
		return
	
	dialog_text.text = "S. > chefe"
	next_dialog = [
		"B. > sillm?",
		"S. > você achou que podia ficar billando por aí sem ninguém descobrir?",
		"B. o que?",
		"S. > o 67. você matill ele. eu sou as consequillcias",
		"B. > como assim?",
		"B. > não fui eu, foi o-",
		"S. > acabou, gêmeo"
	]
	show_dialog()
