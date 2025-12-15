extends Area2D

@onready var sprite: Sprite2D = $Sprite
@onready var cooldown: Timer = $Cooldown

@export_enum("left", "right") var direction: String

var can_interact: bool = false
var is_mouse_over: bool = false
var is_lit: bool = false
var is_closed: bool = false

func _ready() -> void:
	sprite.visible = is_closed

func _on_mouse_entered() -> void:
	is_mouse_over = true
	can_interact = true

func _on_mouse_exited() -> void:
	is_mouse_over = false
	can_interact = false

func _process(delta: float) -> void:
	# só poder interagir quando estiver com as câmeras abaixadas
	if Manager.is_cameras_open:
		return
	
	if !can_interact:
		return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		toggle_door()

func toggle_door():
	can_interact = false
	cooldown.start()
	
	sprite.visible = !sprite.visible
	is_closed = sprite.visible

func _on_cooldown_timeout() -> void:
	# se não tiver a deteção do mouse over
	# ainda daria pra fechar a porta mesmo estando com o mouse longe
	if is_mouse_over:
		can_interact = true
