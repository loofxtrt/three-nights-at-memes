extends Node2D

@onready var manager: Node = $"../Manager"
@onready var camera_sprite: AnimatedSprite2D = $CameraSprite
@onready var blip_flash: AnimatedSprite2D = $BlipFlash
@onready var trigger_sprite: Sprite2D = $"../TabletTrigger/Sprite"
@onready var audio_controller: Node = $"../AudioController"
@onready var camera_switch: AudioStreamPlayer = $"../AudioController/CameraSwitch"

const CHANNEL_BUTTON_THEME = preload("uid://3idyt7myk8tf")
const MONITOR_OFF_SPRITE = preload("uid://d25pm6tqx28e3")
const MONITOR_ON_SPRITE = preload("uid://dj2qmmn1x50lv")

var active_camera: String = "stage"

func _ready() -> void:
	# garantir que as câmeras/efeitos comecem desligados
	# e que a inicial seja sempre a do palco
	visible = false
	blip_flash.visible = false
	
	# atualizar as câmeras quando um animatronic se mover
	manager.animatronic_moved.connect(refresh_current_camera)

func set_active_camera(camera_id: String):
	play_blip_flash()
	
	var animation_name: String
	var frame_index: int = 0
	
	if camera_id == "stage":
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
		animation_name = "stage"
		camera_id = animation_name
		
		if manager.luva_pos == "stage" && manager.virginia_pos == "stage":
			animation_name = "stage_luva_bill_virginia"
		elif manager.luva_pos == "stage" && manager.virginia_pos != "stage":
			animation_name = "stage_luva_bill"
		elif manager.luva_pos != "stage" && manager.virginia_pos == "stage":
			animation_name = "stage_bill_virginia"
	elif camera_id == "hall_left":
		animation_name = "hall_left"
		camera_id = animation_name
		
		if manager.luva_pos == "hall_left":
			animation_name = "hall_left_luva"
	elif camera_id == "hall_right":
		animation_name = "hall_right"
		camera_id = animation_name
		
		if manager.virginia_pos == "hall_right":
			animation_name = "hall_right_virginia"
	elif camera_id == "amostradinho_cove":
		animation_name = "amostradinho_cove"
		camera_id = animation_name
		
		# se for 3, significa que ele tá correndo/batendo na porta do escritório
		# o sprite da pirate cove continua o mesmo do estágio anterior nas câmeras
		if manager.amostradinho_stage > 3:
			frame_index = manager.amostradinho_stage
		else:
			frame_index = 2
		
		# começar a perseguição do amostradinho. automaticamente faz o estágio virar 3
		if manager.amostradinho_stage == 2:
			manager.trigger_amostradinho()
	
	# define as variáveis e atualiza o sprite
	# o frame index serve principalmente pra mostrar o estágio do amostradinho
	active_camera = camera_id
	
	camera_sprite.animation = animation_name
	camera_sprite.frame = frame_index

func play_blip_flash(silent: bool = false):
	if !silent:
		camera_switch.play()
	
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
	visible = !visible
	manager.is_cameras_open = visible
	
	if visible:
		set_active_camera(active_camera) # pro sprite sempre começar atualizado
	
	camera_tips_visible(visible)

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
