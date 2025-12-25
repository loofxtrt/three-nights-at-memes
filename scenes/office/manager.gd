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

var amostradinho_stage: int = 3

signal animatronic_moved

class Animatronic:
	var nick: String
	var ai: int
	var pos: String
	var moving_map: Dictionary
	var manager: Node
	
	func _init(_nick, _ai, _pos, _moving_map, _manager) -> void:
		nick = _nick
		ai = _ai
		pos = _pos
		moving_map = _moving_map
		manager = _manager # precisa pra poder adicionar o timer e conectar funções
	
	func start_movement_timer():
		# o tempo entre cada tentativa de movimento
		# isso é individual. vários podem tentar se mover ao mesmo tempo
		var next_move = Timer.new()
		manager.add_child(next_move)
		
		next_move.wait_time = randf_range(4, 6)
		next_move.one_shot = true
		
		# conectar o timeout com a função pra gerar um loop
		next_move.timeout.connect(
			Callable(manager, "move_animatronic").bind(self)
		)
		
		next_move.start()

var luva = Animatronic.new(
	"luva",
	10,
	"stage",
	{
		"stage": ["hall_left", "kitchen"],
		"kitchen": ["hall_left", "stage"],
		"hall_left": ["stage", "office"]
	},
	self
)
var virginia = Animatronic.new(
	"virginia",
	10,
	"stage",
	{
		"stage": ["hall_right", "kitchen"],
		"kitchen": ["hall_right", "stage"],
		"hall_right": ["stage", "office"]
	},
	self
)
var animatronic_list = [luva, virginia]

func _ready() -> void:
	# setar os timers de movimentação pela primeira vez
	for a in animatronic_list:
		a.start_movement_timer()
	
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

func move_animatronic(animatronic: Animatronic):
	animatronic.start_movement_timer()
	
	var nick = animatronic.nick
	var ai = animatronic.ai
	var moving_map = animatronic.moving_map
	var pos = animatronic.pos
	var new_pos: String
	
	# sorteia um número de x à y, se for maior que o número da ia
	# ele NÃO vai se mover. se for menor que a ia, ele vai se mover
	var movement_rng = randf_range(0, 20)
	if movement_rng > ai:
		print(nick + " tentou se mover mas não conseguiu")
		return
	
	# obter quais salas ele pode ir para, baseado na posição atual
	# com base nisso, atualiza a posição ou dá o jumpscare
	var moves = moving_map.get(pos)

	if pos != "office":
		new_pos = moves.pick_random()
		animatronic.pos = new_pos # a variável real da classe, não a cópia local
	else:
		await get_tree().create_timer(4).timeout
		
		if !is_left_door_closed:
			jumpscare()
		else:
			pos = "stage"
			print(nick + " foi embora")

	animatronic_moved.emit() # útil pra atualizar as câmeras
	print("posição de " + nick + " atualizada para " + animatronic.pos)

func trigger_amostradinho():
	# FIXME: warning toca duas vezes
	# FIXME: nada acontece se abrir a porta antes do audio de batidas terminar
	
	var sfx_warning = audio_controller.amostradinho_warning
	var sfx_running = audio_controller.amostradinho_running
	
	if !sfx_warning.playing:
		audio_controller.amostradinho_warning.play()
	if !sfx_running.playing:
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
