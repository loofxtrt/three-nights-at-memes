extends Node

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
		AudioController.jumpscare.play()
		print(animatronic + " atacou, jumpscare")

func trigger_amostradinho():
	# FIXME: toca duas vezes
	
	# estágio em que ele tá correndo pro escritório ou batendo na porta
	amostradinho_stage = 3
	AudioController.amostradinho_warning.play()
	
	# depois que ele termina de correr (esse timer)
	# porta aberta -> jumpscare
	# porta fechada -> vai embora
	await get_tree().create_timer(2).timeout
	
	if Manager.is_left_door_closed:
		amostradinho_stage = 0
		print("amostradinho foi embora")
	else:
		AudioController.jumpscare.play()
		print("amostradinho entrou na office")

func modify_power(amount: float):
	power += amount
	print("energia atual: " + str(power))
