extends Node

@onready var points_label: Label = $"../Control/PointsLabel"
@onready var player: CharacterBody2D = $"../Player"
@onready var pickup: AudioStreamPlayer = $"../Pickup"
@onready var _8_bit_horror: AudioStreamPlayer = $"../8BitHorror"
@onready var final: Sprite2D = $"../Final"
@onready var background: ColorRect = $"../Background"
@onready var zamn: AudioStreamPlayer = $"../Zamn"

var points = 62

func _ready() -> void:
	update_points_label()
	final.visible = false

func update_points_label():
	points_label.text = "000" + str(points)

func increase_points():
	pickup.play()
	points += 1
	update_points_label()
	
	if points == 65:
		points_label.add_theme_color_override("font_color", Color("f2ada9ff"))
	elif points == 66:
		player.speed -= 50
		points_label.add_theme_color_override("font_color", Color("#d45e5e"))
		background.color = Color("0f0303ff")
		_8_bit_horror.play()
	elif points == 67:
		points_label.add_theme_color_override("font_color", Color("fd4639ff"))
		_8_bit_horror.stop()
		pickup.stop()
		zamn.play()
		
		# depois da cena final aparecer, volta pro escritório
		final.visible = true
		await get_tree().create_timer(2).timeout
		
		
		#var office = load("uid://diw1qplhntkkf")
		SceneManager.to_office()
