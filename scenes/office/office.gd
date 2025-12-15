extends Node2D

@onready var cameras: Node2D = $Cameras
@onready var channel_buttons: VBoxContainer = $Cameras/ChannelButtons

const CHANNEL_BUTTON = preload("uid://3idyt7myk8tf")

var left_light_is_on: bool = false
var left_door_is_closed: bool = false

var right_light_is_on: bool = false
var right_door_is_closed: bool = false

func _ready() -> void:
	cameras.visible = false
	Manager.is_cameras_open = false
	make_channel_buttons()

func make_channel_buttons():
	var amount = 4
	for i in range(amount):
		var button = Button.new()
		button.theme = CHANNEL_BUTTON
		button.text = "CHANNEL " + str(i)
		channel_buttons.add_child(button)

func _on_tablet_trigger_mouse_entered() -> void:
	cameras.visible = !cameras.visible
	is_cameras_open = cameras.visible
