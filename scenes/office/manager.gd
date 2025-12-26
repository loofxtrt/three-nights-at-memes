extends Node

@onready var audio_controller: Node = $"../AudioController"
@onready var jumpscare_sprite: AnimatedSprite2D = $"../JumpscareSprite"
@onready var cameras: Node2D = $"../Cameras"
@onready var power_left: Label = $"../HUD/TopVBox/PowerLeft"
@onready var hotkey_tip: Label = $"../HUD/TopVBox/HotkeyTip"
@onready var bill_standing_sprite: Sprite2D = $"../BillStanding"

var is_cameras_open: bool = false
var power: float = 100.0
var is_left_door_closed: bool = false
var is_right_door_closed: bool = false

var amostradinho_stage: int = 0
var amostradinho_is_running: bool = false
var bill_is_going_to_enter: bool = false
var bill_is_in_the_office: bool = false

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

#var _bill_ai = 10
#var _luva_ai = 10
#var _virginia_ai = 10
#var _amostradinho_ai = 6
var _bill_ai = 20
var _luva_ai = 0
var _virginia_ai = 0
var _amostradinho_ai = 0
var luva = Animatronic.new(
	"luva",
	_luva_ai,
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
	_virginia_ai,
	"stage",
	{
		"stage": ["hall_right", "kitchen"],
		"kitchen": ["hall_right", "stage"],
		"hall_right": ["stage", "office"]
	},
	self
)
var bill = Animatronic.new(
	"bill",
	_bill_ai,
	"stage",
	{
		"stage": ["hall_right"],
		"hall_right": ["stage", "office"]
	},
	self
)
var amostradinho = Animatronic.new(
	"amostradinho",
	_amostradinho_ai,
	"amostradinho_cove",
	{},
	self
)
var animatronic_list = [bill, luva, virginia, amostradinho]

func _ready() -> void:
	tip_visible(false)
	bill_standing_sprite.visible = false
	
	# setar os timers de movimentação pela primeira vez
	for a in animatronic_list:
		a.start_movement_timer()

func _process(delta: float) -> void:
	# atualizar os dados relacionados à energia
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
	
	# parar possíveis áudios que estejam tocando
	audio_controller.ambience.stop()
	audio_controller.amostradinho_knocking.stop()
	
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
	
	# o amostradinho é um caso especial porque ele não se move,
	# só avança o estado dele na amostradinho cove
	if animatronic == amostradinho:
		amostradinho_stage += 1
		animatronic_moved.emit()
		print("amostradinho avançõou mais um estágio")
		return
	
	# obter quais salas ele pode ir para, baseado na posição atual
	# com base nisso, atualiza a posição ou dá o jumpscare
	var moves = moving_map.get(pos)

	if pos != "office":
		new_pos = moves.pick_random()
		animatronic.pos = new_pos # tem que ser a variável real da classe, não a cópia local
	else:
		# se o animatronic for o bill, ele não entra automaticamente
		# ele espera a próxima vez que as câmeras forem triggadas pra ele entrar
		if animatronic == bill:
			trigger_bill()
			return
		
		# tempo até ele desistir ou entrar no escritório
		await get_tree().create_timer(4).timeout
		
		# a porta a ser fechada deve ser a de onde o animatronic vem
		var is_targeted_door_closed
		if animatronic == luva:
			is_targeted_door_closed = is_left_door_closed
		elif animatronic == virginia || animatronic == bill:
			is_targeted_door_closed = is_right_door_closed
		
		if !is_targeted_door_closed:
			jumpscare()
		else:
			pos = "stage"
			audio_controller.going_away.play() # indicador de que é seguro abrir a porta
			print(nick + " foi embora")

	animatronic_moved.emit() # útil pra atualizar as câmeras
	print("posição de " + nick + " atualizada para " + animatronic.pos)

func trigger_bill():
	print("bill vai entrar na sala quando levantar as câmeras")
	bill_is_going_to_enter = true
	
	#if is_cameras_open:
	cameras.cameras_off.connect(_on_cameras_off)
	#else:
	#	cameras.cameras_on.connect(trigger_bill)

	## quando esse som acabar, é seguro abaixar as câmeras
	#audio_controller.animatronic_in_office.play()
	#await audio_controller.animatronic_in_office.finished
	#
	#bill_is_in_the_office = false
	#bill_is_going_to_enter = false
	#bill.pos = "stage"

func _on_cameras_off():
	if !bill_is_in_the_office:
		bill_standing_sprite.visible = true
		bill_is_in_the_office = true
		
		audio_controller.animatronic_in_office.play()
		
		# tempo de tolerância pra levantar as câmeras de novo
		await get_tree().create_timer(1.2).timeout
	
		if not is_cameras_open:
			jumpscare()
		
		# quando esse som acabar, é seguro abaixar as câmeras
		await audio_controller.animatronic_in_office.finished
		bill_is_in_the_office = false
		bill_is_going_to_enter = false
		bill.pos = "stage"
	else:
		# se abaixar as câmeras antes dele ir embora, também morre
		jumpscare()

func trigger_amostradinho():
	# não toca os eventos se já foi indentificado que ele saiu da cove
	# assim, os sfx não tocam duas vezes
	if amostradinho_is_running:
		return
	
	var sfx_warning = audio_controller.amostradinho_warning
	var sfx_running = audio_controller.amostradinho_running
	
	if !sfx_warning.playing:
		audio_controller.amostradinho_warning.play()
	if !sfx_running.playing:
		audio_controller.amostradinho_running.play()
	
	# registro de que não precisa mais tocar os sfx de novo
	amostradinho_is_running = true
	
	# quanto tempo ele demora pra chegar na sala
	var running_duration = 2
	await get_tree().create_timer(running_duration).timeout
	
	if is_left_door_closed:
		# tocar o áudio de batidas. se a porta for aberta antes dele acabar
		# o jumpscare acontece mesmo assim. isso tá embutido no código da porta
		var knocking_sfx = audio_controller.amostradinho_knocking
		
		knocking_sfx.play()
		await knocking_sfx.finished
		
		# quando o áudio acabar, significa que ele parou de bater na porta
		# e voltou pra cove, então é seguro abrir a porta de novo
		amostradinho_stage = 0
		amostradinho_is_running = false
		cameras.refresh_current_camera()
		modify_power(-randf_range(2, 4)) # ele também drena energia extra quando vai embora
		
		print("amostradinho foi embora")
	else:
		jumpscare()

func modify_power(amount: float):
	amount = amount / 50
	power += amount
	#print("energia atual: " + str(power))
