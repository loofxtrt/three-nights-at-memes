extends Node2D

@onready var manager: Node = $"../Manager"
@onready var camera_sprite: AnimatedSprite2D = $CameraSprite
@onready var channel_buttons: VBoxContainer = $ChannelButtons

const CHANNEL_BUTTON_THEME = preload("uid://3idyt7myk8tf")

var active_camera: String = "stage"
var active_channel: int = 0

func _ready() -> void:
	# garantir que as câmeras comecem desligadas
	# e que a inicial seja sempre a do palco
	visible = false
	make_channel_buttons()
	
	set_active_camera(0)
	
	# atualizar as câmeras quando um animatronic se mover
	manager.animatronic_moved.connect(refresh_current_camera)

func make_channel_buttons():
	# limpar todos os botões antes de desenhar eles de novo
	for c in channel_buttons.get_children():
		c.queue_free()
	
	# cria um botão pra cada câmera
	# baseado no número de câmeras definido pelo amount
	var amount = 4
	for i in range(amount):
		var button = Button.new()
		
		# aplicar o tema e texto, adicionando o botão à vbox
		button.theme = CHANNEL_BUTTON_THEME
		button.text = "CHANNEL " + str(i)
		
		channel_buttons.add_child(button)
		
		# conecta o botão a um índice de câmera
		# o i é o número que a câmera recebe
		button.pressed.connect(set_active_camera.bind(i))

func set_active_camera(channel_number: int):
	var animation_name: String
	var camera_id: String
	var frame_index: int = 0

	if channel_number == 0:
		animation_name = "stage"
		camera_id = animation_name
	elif channel_number == 1:
		animation_name = "hall_left"
		camera_id = animation_name
		
		if manager.luva_pos == "hall_left":
			animation_name = "hall_left_luva"
	elif channel_number == 2:
		animation_name = "hall_right"
		camera_id = animation_name
		
		if manager.virginia_pos == "hall_right":
			animation_name = "hall_right_virginia"
	elif channel_number == 3:
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
	active_channel = channel_number
	
	camera_sprite.animation = animation_name
	camera_sprite.frame = frame_index

func refresh_current_camera():
	# pra usar quando um animatronic se move enquanto
	# o player já está olhando a câmera que ele entrou/saiu
	print("recarregando a câmera")
	set_active_camera(active_channel)

func toggle_cameras():
	visible = !visible
	manager.is_cameras_open = visible

func _on_tablet_trigger_mouse_entered() -> void:
	toggle_cameras()
