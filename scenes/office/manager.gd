extends Node

@onready var audio_controller: Node = $"../AudioController"
@onready var jumpscare_sprite: AnimatedSprite2D = $"../JumpscareSprite"
@onready var cameras: Node2D = $"../Cameras"
@onready var power_left: Label = $"../HUD/TopVBox/PowerLeft"
@onready var hotkey_tip: Label = $"../HUD/TopVBox/HotkeyTip"

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
	# acionar o timer de movimentação dos animatronics pela primeira vez
	next_move = Timer.new()
	next_move.one_shot = true
	add_child(next_move)
	
	next_move.timeout.connect(move_animatronic)
	start_movement_timer()
	
	tip_visible(false)

func _process(delta: float) -> void:
	power_left.text = "billteria: " + str(round(power))
	
	if is_right_door_closed or is_left_door_closed:
		modify_power(-0.2)

func set_tip(tips: Array):
	# recebe um array de dicas. cada item é uma linha
	# ex: [["e", "interagir"]]
	var text = ""
	
	for t in tips:
		var key = t[0] as String
		var action = t[1] as String
		
		key = "[" + key.to_upper() + "]"
		text += key + " " + action + "\n"
	
	hotkey_tip.text = text

func tip_visible(state: bool):
	hotkey_tip.visible = state

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
	if animatronic == "virginia":
		return
	
	if animatronic == "luva":
		var moving_map = {
			"stage": ["hall_left", "kitchen"],
			"kitchen": ["hall_left", "stage"],
			"hall_left": ["stage", "office"]
		}
		var moves = moving_map.get(luva_pos)

		if luva_pos != "office":
			new_pos = moves.pick_random()
			luva_pos = new_pos
		else:
			await get_tree().create_timer(4).timeout
			
			if !is_left_door_closed:
				jumpscare()
			else:
				luva_pos = "stage"
				print("luva foi embora")
	elif animatronic == "virginia":
		if virginia_pos == "stage":
			possible_next = ["hall_right"]
		elif virginia_pos == "hall_right":
			possible_next = ["office"]
		
		new_pos = possible_next.pick_random()
		virginia_pos = new_pos

	animatronic_moved.emit() # útil pra atualizar as câmeras
	print("posição de " + animatronic + " atualizada")
	
	#if new_pos == "office":
	#	await get_tree().create_timer(4).timeout
	#
	#	jumpscare()
	#	print(animatronic + " atacou, jumpscare")

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

func modify_power(amount: float):
	amount = amount / 50
	power += amount
	#print("energia atual: " + str(power))
