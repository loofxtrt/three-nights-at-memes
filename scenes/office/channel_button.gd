extends TextureButton

# IMPORTANTE
# essa cena deve ter o buttongroup carregado como preload, pra garantir que ele sempre é o mesmo
# em textures, só normal e focused devem ter sprites

@onready var cameras: Node2D = $".."

@export var camera_id: String
@export var initial_state: bool = false

const CHANNEL_BUTTONS_GROUP = preload("uid://c0uojks4imd8r")

func _ready() -> void:
	button_group = CHANNEL_BUTTONS_GROUP
	toggle_mode = true
	
	print("adicionado " + name + " ao buttongroup " + str(button_group))
	
	# definir o botão como modo de checkbox
	# e já começar com ele pressionado se assim especificado
	if initial_state:
		button_pressed = true
	
	pressed.connect(_on_pressed)

func _on_pressed():
	cameras.set_active_camera(camera_id)
