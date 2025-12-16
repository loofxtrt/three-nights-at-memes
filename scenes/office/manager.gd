extends Node

@onready var audio_controller: Node = $"../AudioController"
@onready var jumpscare_sprite: AnimatedSprite2D = $"../JumpscareSprite"
@onready var cameras: Node2D = $"../Cameras"
@onready var power_left: Label = $"../HUD/PowerLeft"

var is_cameras_open: bool = false
var power: float = 100.0

var is_left_door_closed: bool = false
var is_right_door_closed: bool = false

var luva_pos = "stage"
var virginia_pos = "stage"
var bill_pos = "stage"
var amostradinho_stage: int = 2

var next_move: Timer

signal animatronic_moved

func _ready() -> void:
	next_move = Timer.new()
	next_move.one_shot = true
	add_child(next_move)
	
	next_move.timeout.connect(move_animatronic)
	start_movement_timer()

func _process(delta: float) -> void:
	power_left.text = str(round(power))
	
	if is_right_door_closed or is_left_door_closed:
		modify_power(-0.2)

func jumpscare():
	# abaixar as câmeras antes de dar o jumpscare
	if is_cameras_open:
		cameras.toggle_cameras()
	
	# fazer a animação ser visível e tocar o som
	jumpscare_sprite.visible = true
	jumpscare_sprite.animation = "bill"
	jumpscare_sprite.play()
	audio_controller.jumpscare.play()

func start_movement_timer():
	#next_move.wait_time = randf_range(20, 45)
	next_move.wait_time = randf_range(5, 10)
	next_move.start()

func move_animatronic(animatronic: String = ""):
	start_movement_timer()
	var possible_next = []
	var new_pos: String
	
	if animatronic == "":
		animatronic = ["luva", "virginia"].pick_random()
	
	if animatronic == "luva":
		if luva_pos == "stage":
			possible_next = ["hall_left"]
		elif luva_pos == "hall_left":
			possible_next = ["office"]

		new_pos = possible_next.pick_random()
		luva_pos = new_pos
	elif animatronic == "virginia":
		if virginia_pos == "stage":
			possible_next = ["hall_right"]
		elif virginia_pos == "hall_right":
			possible_next = ["office"]
		
		new_pos = possible_next.pick_random()
		virginia_pos = new_pos

	animatronic_moved.emit() # útil pra atualizar as câmeras
	print("posição de " + animatronic + " atualizada")
	
	if new_pos == "office":
		jumpscare()
		print(animatronic + " atacou, jumpscare")

func trigger_amostradinho():
	# FIXME: warning toca duas vezes
	# FIXME: nada acontece se abrir a porta antes do audio de batidas terminar
	
	# estágio em que ele tá correndo pro escritório ou batendo na porta
	amostradinho_stage = 3
	audio_controller.amostradinho_warning.play()
	audio_controller.amostradinho_running.play()
	
	# depois que ele termina de correr (esse timer)
	# porta aberta -> jumpscare
	# porta fechada -> vai embora
	await get_tree().create_timer(2).timeout
	
	if is_left_door_closed:
		audio_controller.amostradinho_knocking.play()
		amostradinho_stage = 0
		print("amostradinho foi embora")
	else:
		jumpscare()
		print("amostradinho entrou na office")

func modify_power(amount: float):
	amount = amount / 50
	power += amount
	print("energia atual: " + str(power))
