extends Node2D

@onready var manager: Node = $"../Manager"
@onready var camera_sprite: AnimatedSprite2D = $CameraSprite
@onready var blip_flash: AnimatedSprite2D = $BlipFlash
@onready var trigger_sprite: Sprite2D = $"../TabletTrigger/Sprite"
@onready var audio_controller: Node = $"../AudioController"
@onready var camera_switch: AudioStreamPlayer = $"../AudioController/CameraSwitch"

const CHANNEL_BUTTON_THEME = preload("uid://3idyt7myk8tf")
const MONITOR_OFF_SPRITE = preload("uid://btbr5s1vgs8yx")
const MONITOR_ON_SPRITE = preload("uid://b45mlhu0dbrfl")

var active_camera: String = "stage"

signal cameras_on
signal cameras_off

func _ready() -> void:
	# garantir que as câmeras/efeitos comecem desligados
	# e que a inicial seja sempre a do palco
	visible = false
	blip_flash.visible = false
	
	# atualizar as câmeras quando um animatronic se mover
	manager.animatronic_moved.connect(refresh_current_camera)

func set_active_camera(camera_id: String, trigger_blip_flash: bool = true):
	if trigger_blip_flash:
		play_blip_flash()
	
	var animation_name: String
	var frame_index: int = 0
	
	var luva_pos = manager.luva.pos
	var virginia_pos = manager.virginia.pos
	var bill_pos = manager.bill.pos
	
	var sprite_map = [
		{
			"animatronics": ["luva", "bill", "virginia"],
			"sprite": "stage_luva_bill_virginia"
		},
		{
			"animatronics": ["luva", "bill"],
			"sprite": "stage_luva_bill"
		},
		{
			"animatronics": ["bill", "virginia"],
			"sprite": "stage_bill_virginia"
		},
		{
			"animatronics": [],
			"sprite": "stage"
		}
	]
	
	if camera_id == "stage":
		var b = bill_pos == "stage"
		var l = luva_pos == "stage"
		var v = virginia_pos == "stage"
		animation_name = "stage"
		
		if l && v && b:
			animation_name = "stage_luva_bill_virginia"
		elif l && b && !v:
			animation_name = "stage_luva_bill"
		elif b && v && !l:
			animation_name = "stage_bill_virginia"
		elif b && !v && !l:
			animation_name = "stage_bill"
		else:
			animation_name = "no_signal"
	elif camera_id == "amostradinho_cove":
		animation_name = "amostradinho_cove"
		frame_index = manager.amostradinho_stage
		
		# se for 3, significa que ele tá correndo/batendo na porta do escritório
		# ele começa a correr quando a câmera muda pra amostradinho cove
		if manager.amostradinho_stage == 3:
			manager.trigger_amostradinho()
	else:
		# casos de câmeras normais, que só luva e virginia aparecem
		# isso assume que a ordem de nomeação vai ser sempre _luva_virginia
		animation_name = camera_id
		var present = []
		if luva_pos == camera_id:
			present.append("luva")
		if virginia_pos == camera_id:
			present.append("virginia")
	
		if present.size() > 0:
			animation_name = animation_name + "_" + "_".join(present)

	# define as variáveis e atualiza o sprite
	# o frame index serve principalmente pra mostrar o estágio do amostradinho
	active_camera = camera_id
	
	camera_sprite.animation = animation_name
	camera_sprite.frame = frame_index

func play_blip_flash():
	if !manager.is_cameras_open:
		return
	
	camera_switch.play() # áudio
	
	blip_flash.visible = true
	blip_flash.play()

func refresh_current_camera():
	# pra usar quando um animatronic se move enquanto
	# o player já está olhando a câmera que ele entrou/saiu
	print("recarregando a câmera")
	set_active_camera(active_camera)

func camera_tips_visible(state):
	# mostrar as dicas de hotkeys da câmera
	manager.set_tip([["e", "câmeras"]])
	manager.tip_visible(state)

func toggle_cameras():
	if !manager.can_interact:
		return
	
	var state = !visible # oposto do estado anterior
	
	visible = state
	manager.is_cameras_open = state
	
	if state:
		cameras_on.emit()
		set_active_camera(active_camera) # pro sprite sempre começar atualizado
	else:
		cameras_off.emit()
	
	camera_tips_visible(state)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cameras"):
		toggle_cameras()

func _on_tablet_trigger_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if manager.is_cameras_open:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			toggle_cameras()

func _on_tablet_trigger_mouse_entered() -> void:
	trigger_sprite.texture = MONITOR_ON_SPRITE
	camera_tips_visible(true)

func _on_tablet_trigger_mouse_exited() -> void:
	trigger_sprite.texture = MONITOR_OFF_SPRITE
	
	if !manager.is_cameras_open:
		camera_tips_visible(false)

func _on_blip_flash_animation_finished() -> void:
	blip_flash.visible = false
