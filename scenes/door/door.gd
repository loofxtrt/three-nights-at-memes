extends Area2D

@onready var sprite: Sprite2D = $Sprite
@onready var cooldown: Timer = $Cooldown

@export var manager: Node
@export var audio_controller: Node
@export_enum("left", "right") var direction: String

var can_interact: bool = false
var is_mouse_over: bool = false
var is_closed: bool = false

func _ready() -> void:
	sprite.visible = is_closed

func _on_mouse_entered() -> void:
	is_mouse_over = true
	can_interact = true
	
	if !manager.is_cameras_open:
		manager.set_tip([["lmb", "porta"], ["ctrl", "luz"]])
		manager.tip_visible(true)

func _on_mouse_exited() -> void:
	is_mouse_over = false
	can_interact = false
	
	if !manager.is_cameras_open:
		manager.tip_visible(false)

func _process(delta: float) -> void:
	# só poder interagir quando estiver com as câmeras abaixadas
	if manager.is_cameras_open || !can_interact:
		return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		toggle_door()

func toggle_door():
	# cooldown até poder fechar/abrir de novo
	can_interact = false
	cooldown.start()
	
	# fechar/abrir a porta
	sprite.visible = !sprite.visible
	is_closed = sprite.visible
	
	if direction == "right":
		manager.is_right_door_closed = is_closed
	elif direction == "left":
		manager.is_left_door_closed = is_closed
		
		if manager.amostradinho_is_running && !is_closed:
			# fazer o amostradinho dar o jumpscare se abrir a porta
			# sem esperar ele ir embora antes if amostradinho_is_running && !is_left_door_closed: jumpscare()
			manager.jumpscare()
	
	audio_controller.door_slam.play()

func _on_cooldown_timeout() -> void:
	# se não tivevesse a deteção do mouse over
	# ainda daria pra fechar a porta mesmo estando com o mouse longe
	if is_mouse_over:
		can_interact = true
