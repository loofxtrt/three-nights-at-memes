extends Area2D

@export var manager: Node
@export_enum("left", "right") var direction: String

var is_lit: bool = false
var can_interact: bool = false

var office: Node2D = null

const OFFICE_LIGHT_LEFT = preload("uid://cjllu4k2hgryc")
const OFFICE_LIGHT_RIGHT = preload("uid://de5y2e2h1y3wq")
const OFFICE_LUVA_LEFT = preload("uid://jelo5cpmorhr")
const OFFICE_VIRGINIA_RIGHT = preload("uid://bui7w38p6m5sw")
const OFFICE = preload("uid://soeplbijsxai")

func _ready() -> void:
	office = get_tree().get_first_node_in_group("office")

func _on_mouse_entered() -> void:
	can_interact = true

func _on_mouse_exited() -> void:
	can_interact = false
	set_light(false) # deve apagar a luz sempre que o mouse sair, não só quando soltar o botão

func _input(event: InputEvent) -> void:
	# só poder interagir quando estiver com as câmeras abaixadas
	if manager.is_cameras_open:
		return
	
	if can_interact && event.is_action_pressed("light"):
		set_light(true)
	elif event.is_action_released("light"):
		set_light(false)

func _process(delta: float) -> void:
	# subtrair energia enquanto uma das luzes estiver ligada
	if is_lit:
		manager.modify_power(-0.1)

func reset_office_lights(office_sprite: Sprite2D):
	office_sprite.texture = OFFICE

func set_light(state: bool):
	# define o estado da luz, seja apagado ou aceso
	is_lit = state
	print("estado da lanterna: " + str(is_lit))
	
	var office_sprite = office.get_node("Sprite")
	if !office_sprite:
		print("node do sprite da office nao obtido")
		return
	
	# não precisa de lógica pra só um botão poder ser apertado por vez
	# porque o mouse já precisa estar sobre um de qualquer modo,
	# então já é teoricamente impossível usar as duas luzes de uma vez
	if direction == "left":
		if is_lit:
			office_sprite.texture = OFFICE_LIGHT_LEFT
		else:
			reset_office_lights(office_sprite)
	elif direction == "right":
		if is_lit:
			office_sprite.texture = OFFICE_LIGHT_RIGHT
		else:
			reset_office_lights(office_sprite)
	else:
		return
