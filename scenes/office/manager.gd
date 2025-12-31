extends Node

@onready var office_sprite: Sprite2D = $"../Sprite"
@onready var audio_controller: Node = $"../AudioController"
@onready var jumpscare_sprite: AnimatedSprite2D = $"../JumpscareSprite"
@onready var cameras: Node2D = $"../Cameras"
@onready var hotkey_tip: Label = $"../HUD/HotkeyTip"
@onready var power_left: Label = $"../HUD/PowerVBox/PowerLeft"
@onready var current_usage: Label = $"../HUD/PowerVBox/UsageHBox/CurrentUsage"
@onready var usage_bars: HBoxContainer = $"../HUD/PowerVBox/UsageHBox/UsageBars"
@onready var bill_standing_sprite: Sprite2D = $"../BillStanding"
@onready var breathing_animation: AnimationPlayer = $"../Mask/BreathingAnimation"
@onready var mask_sprite: Sprite2D = $"../Mask"
@onready var flickering_animation: AnimationPlayer = $"../LightFlick/FlickeringAnimation"
@onready var light_flick_rect: ColorRect = $"../LightFlick"
@onready var night_timer: Timer = $"../NightTimer"
@onready var power_tick: Timer = $"../PowerTick"
@onready var clock_label: Label = $"../HUD/ClockVBox/ClockLabel"
@onready var night_label: Label = $"../HUD/ClockVBox/NightLabel"
@onready var bill_power_outage: Sprite2D = $"../BillPowerOutage"
@onready var tablet_trigger: Area2D = $"../TabletTrigger"
@onready var decoration: Node2D = $"../Decoration"
@onready var shadows: Sprite2D = $"../Shadows"
@onready var blackout: ColorRect = $"../Blackout"

const COMPLETION_SCREEN = preload("uid://dah2e3e275agu")
const USAGE_WHITE = preload("uid://c188asmil3hig")
const OFFICE_POWER_OUT = preload("uid://dormbbba2hwdr")

var is_cameras_open: bool = false
var is_mask_on: bool = false
var is_left_door_closed: bool = false
var is_right_door_closed: bool = false
var can_interact: bool = true
var power: float = 10.0
var usage: int = 1
var night: int = 1
var night_duration_minutes: int = 3
var lock_tips: bool = false

var amostradinho_stage: int = 0
var amostradinho_is_running: bool = false
var bill_is_going_to_enter: bool = false
var bill_is_in_the_office: bool = false

signal animatronic_moved
signal mask_off
signal mask_on
signal power_modified

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
	0,
	"stage",
	{
		"stage": ["hall_left", "kitchen"],
		"kitchen": ["hall_left", "stage", "backstage"],
		"backstage": ["hall_left"],
		"hall_left": ["backstage", "office"]
	},
	self
)
var virginia = Animatronic.new(
	"virginia",
	0,
	"stage",
	{
		"stage": ["hall_right", "kitchen"],
		"kitchen": ["hall_right", "stage"],
		"backstage": ["hall_right"],
		"hall_right": ["backstage", "office"]
	},
	self
)
var bill = Animatronic.new(
	"bill",
	0,
	"stage",
	{
		# não faz diferença nas câmeras, só faz ele atrasar igual os outros
		"stage": ["hall_right", "kitchen"],
		"kitchen": ["hall_right"],
		"hall_right": ["stage", "office"]
	},
	self
)
var amostradinho = Animatronic.new(
	"amostradinho",
	0,
	"amostradinho_cove",
	{},
	self
)
var animatronic_list = [bill, luva, virginia, amostradinho]

func _ready() -> void:
	tip_visible(false)
	bill_standing_sprite.visible = false
	bill_power_outage.visible = false
	mask_sprite.visible = false
	light_flick_rect.visible = false
	
	can_interact = true
	lock_tips = false
	
	night = Progress.load_progress()
	night_label.text = "noite " + str(night)
	set_night_duration_minutes(night_duration_minutes)
	
	power_tick.start() # timer de quanto em quanto tempo a energia é drenada
	power_tick.one_shot = true # pra ele não recomeçar quando já tá sem energia
	
	# setar os timers de movimentação pela primeira vez
	for a in animatronic_list:
		a.start_movement_timer()
	
	# ia dos animatronics
	set_animatronics_ai()
	for a in animatronic_list:
		print(a.nick + ": " + str(a.ai))
	
	power_modified.connect(_on_power_modified)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("mask"):
		toggle_mask()
	
	# atualizar os dados relacionados à energia
	power_left.text = "billteria: " + str(roundi(power))
	current_usage.text = "usage: " + str(usage)
	
	#if is_right_door_closed or is_left_door_closed:
	#	modify_power(-0.2)
	
	# atualizar o relógio
	clock_label.text = str(roundf(night_timer.time_left))

func set_animatronics_ai():
	# obtém qual ia cada animatronic deve ter em cada noite
	# e setta a ia atual deles pra condizer com isso
	var ai_night_map = {
		1: {
			"luva_ai": 4,
			"bill_ai": 2,
			"virginia_ai": 4,
			"amostradinho_ai": 3
		},
		2: {
			"luva_ai": 6,
			"bill_ai": 6,
			"virginia_ai": 5,
			"amostradinho_ai": 5
		},
		3: {
			"luva_ai": 7,
			"bill_ai": 9,
			"virginia_ai": 7,
			"amostradinho_ai": 6
		}
	}
	var values = ai_night_map.get(night) # pega o mapa da noite atual
	
	# não tem mais noites que isso, mas dá pra continuar jogando
	if !values:
		ai_night_map.get(3)
	
	luva.ai = values.get("luva_ai")
	bill.ai = values.get("bill_ai")
	virginia.ai = values.get("virginia_ai")
	amostradinho.ai = values.get("amostradinho_ai")

func set_night_duration_minutes(minutes: int, seconds: int = 0):
	night_timer.one_shot = true
	night_timer.autostart = true

	#minutes = 0
	#seconds = 5
	
	# passar tudo pra segundos
	var total_seconds = minutes * 60
	total_seconds += seconds
	night_timer.wait_time = total_seconds
	
	# FIXME: talvez tenha que verificar se já não começou antes
	night_timer.start()

func set_tip(tips: Array):
	if lock_tips:
		return
	
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
	# se o lock tips estiver ativo, não mostra independente da circunstância
	if lock_tips:
		hotkey_tip.visible = false
		return
	
	# sempre mostrar a tip da máscara quando outras não estiverem sendo exibidas
	if state == false:
		hotkey_tip.visible = true
		set_tip([["space", "máscara"]])
		return
	
	hotkey_tip.visible = state

func toggle_mask():
	if is_cameras_open || power <= 0:
		return
	
	mask_sprite.visible = !mask_sprite.visible
	is_mask_on = mask_sprite.visible
	
	if is_mask_on:
		mask_on.emit()
		can_interact = false
		
		# tocar o áudio
		breathing_animation.play("mask_idling")
		audio_controller.mask_on.play()
		if !audio_controller.breathing.playing:
			audio_controller.breathing.play()
	else:
		mask_off.emit()
		can_interact = true
		
		# parar o áudio
		audio_controller.mask_off.play()
		breathing_animation.stop()
		audio_controller.breathing.stop()

func jumpscare():
	can_interact = false
	
	# desligar os mecanismos antes de dar o jumpscare
	if is_cameras_open:
		cameras.toggle_cameras()
	if is_mask_on:
		toggle_mask()
	
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
		
		# tempo até o animatronic desistir ou entrar no escritório
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
	
	if !cameras.cameras_off.is_connected(_on_cameras_off):
		cameras.cameras_off.connect(_on_cameras_off)
	if !mask_off.is_connected(_on_mask_off):
		mask_off.connect(_on_mask_off)

func _on_mask_off():
	# se ele já estiver na sala e tirar a máscara antes dele ir embora, morre
	if bill_is_in_the_office:
		jumpscare()
	
	mask_off.disconnect(_on_mask_off)

func _on_cameras_off():
	if !bill_is_in_the_office:
		bill_standing_sprite.visible = true
		bill_is_in_the_office = true
		
		light_flick_rect.visible = true
		flickering_animation.play("light_flick")
		audio_controller.animatronic_in_office.play()
		
		# tempo de tolerância pra levantar colocar a máscara
		await get_tree().create_timer(1.2).timeout
	
		if not is_mask_on:
			jumpscare()
		
		# quando esse som acabar, é seguro tirar a máscara
		await audio_controller.animatronic_in_office.finished
		
		bill_standing_sprite.visible = false
		bill_is_in_the_office = false
		bill_is_going_to_enter = false
		bill.pos = "stage"
		
		flickering_animation.stop()
		light_flick_rect.visible = false
		
		cameras.cameras_off.disconnect(_on_cameras_off)

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

func increase_usage(state: bool):
	if state:
		usage += 1
		
		#var segment = TextureRect.new()
		#segment.texture = USAGE_WHITE
		#segment.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		#segment.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		#segment.stretch_mode = TextureRect.STRETCH_SCALE
		#usage_bars.add_child(segment)
	elif !state && usage != 1:
		usage -= 1
		
		#var segment = usage_bars.get_child(-1)
		#usage_bars.remove_child(segment)
	
	print("usage: " + str(usage))
	#current_usage.text = "usage: " + str(usage)

func _on_night_timer_timeout() -> void:
	night += 1
	Progress.save_progress(night)
	SceneManager.to_completion_screen()
	#get_tree().change_scene_to_packed(COMPLETION_SCREEN)

func _on_power_modified():
	# essa função só serve pra cortar a luz, então não precisa fazer nada
	# se ainda tiver energia disponível
	if !power <= 0:
		return
	
	# desligar todos os sistemas e travar as interações
	if is_cameras_open:
		cameras.toggle_cameras()
	
	for l in get_tree().get_nodes_in_group("lightables"):
		l.set_light(false)
	
	for d in get_tree().get_nodes_in_group("doors"):
		if d.is_closed:
			d.toggle_door()
	
	can_interact = false
	lock_tips = true
	
	# parar a ambiência e trocar os sprites
	audio_controller.ambience.stop()
	
	office_sprite.texture = OFFICE_POWER_OUT
	decoration.visible = false
	tablet_trigger.visible = false
	shadows.visible = false
	
	# tocar as duas fases do outage, a primeira com o áudio das luzes apagando
	# e a segunda com o bill na porta esquerda
	audio_controller.power_outage.play()
	await audio_controller.power_outage.finished
	
	bill_power_outage.visible = true
	
	audio_controller.bills_lullaby.play()
	await audio_controller.bills_lullaby.finished
	
	jumpscare()

func _on_power_tick_timeout() -> void:
	# toda vez que o tick acaba, a energia é atualizada
	# e depois o ciclo recomeça (se ainda tiver energia)
	power -= float(usage) / 5
	power = max(0.0, power) # pra nunca ficar a baixo de 0
	power_modified.emit()
	
	if power > 0:
		power_tick.start()
	#print(str(power))
