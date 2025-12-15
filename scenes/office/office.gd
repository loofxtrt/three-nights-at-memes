extends Node2D

@onready var cameras: Node2D = $Cameras
@onready var camera_sprite: AnimatedSprite2D = $Cameras/Sprite
@onready var channel_buttons: VBoxContainer = $Cameras/ChannelButtons

const CHANNEL_BUTTON_THEME = preload("uid://3idyt7myk8tf")

var left_light_is_on: bool = false
var left_door_is_closed: bool = false

var right_light_is_on: bool = false
var right_door_is_closed: bool = false

func _ready() -> void:
	cameras.visible = false
	Manager.is_cameras_open = false
	make_channel_buttons()
	set_active_camera(0)

func make_channel_buttons():
	# cria um botão pra cada câmera
	# baseado no número de câmeras definido pelo amount
	var amount = 4
	for i in range(amount):
		var button = Button.new()
		
		button.theme = CHANNEL_BUTTON_THEME
		button.text = "CHANNEL " + str(i)
		
		channel_buttons.add_child(button)
		
		# conecta o botão a um índice de câmera
		# o i é o número que a câmera recebe
		button.pressed.connect(set_active_camera.bind(i))

func set_active_camera(channel_number: int):
	if channel_number == 0:
		camera_sprite.animation = "stage"
	elif channel_number == 1:
		camera_sprite.animation = "hall_left"
	elif channel_number == 2:
		camera_sprite.animation = "hall_right"
	elif channel_number == 3:
		camera_sprite.animation = "amostradinho_cove"
		camera_sprite.frame = Manager.amostradinho_stage

func _on_tablet_trigger_mouse_entered() -> void:
	cameras.visible = !cameras.visible
	Manager.is_cameras_open = cameras.visible
