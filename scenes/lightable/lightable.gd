extends Area2D

@export var manager: Node
@export var audio_controller: Node
@export_enum("left", "right") var direction: String

var is_lit: bool = false
var can_interact: bool = false

var office: Node2D = null

const OFFICE = preload("uid://dejvws08oqqy0")
const OFFICE_LIGHT_LEFT = preload("uid://do8qvsoucsoe5")
const OFFICE_LIGHT_RIGHT = preload("uid://dt7mp53vcaggq")
const OFFICE_LUVA_LEFT = preload("uid://yk4nsp7rj4uo")
const OFFICE_VIRGINIA_RIGHT = preload("uid://c1ndoc7edjjnv")

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
	#print("estado da lanterna: " + str(is_lit))
	
	if is_lit:
		audio_controller.light_flicker.play()
	else:
		audio_controller.light_flicker.stop()
	
	var office_sprite = office.get_node("Sprite")
	if !office_sprite:
		print("node do sprite da office nao obtido")
		return
	
	# não precisa de lógica pra só um botão poder ser apertado por vez
	# porque o mouse já precisa estar sobre um de qualquer modo,
	# então já é teoricamente impossível usar as duas luzes de uma vez
	var directional_methods = {
		"left": {
			"lit": OFFICE_LIGHT_LEFT,        # sprite da porta quando não tem nada
			"animatronic": OFFICE_LUVA_LEFT, # sprite de quando tem o animatronic na portta
			"pos": manager.luva.pos          # posição que deve ser levada em consideração pra mostrar o sprite
		},
		"right": {
			"lit": OFFICE_LIGHT_RIGHT,
			"animatronic": OFFICE_VIRGINIA_RIGHT,
			"pos": manager.virginia.pos
		}
	}
	
	var methods = directional_methods.get(direction)
	var lit_sprite = methods.get("lit")
	var animatronic_sprite = methods.get("animatronic")
	var pos = methods.get("pos")
	
	if is_lit:
		if pos == "office":
			office_sprite.texture = animatronic_sprite
		else:
			office_sprite.texture = lit_sprite
	else:
		reset_office_lights(office_sprite)
