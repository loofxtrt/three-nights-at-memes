extends Node2D

@onready var bill_sprite: Sprite2D = $BillSprite
@onready var _67_sprite: Sprite2D = $"67Sprite"
@onready var dialog_text: Label = $CanvasLayer/DialogText
@onready var fire: AudioStreamPlayer = $Fire
@onready var success: AudioStreamPlayer = $Success
@onready var heartbeat: AudioStreamPlayer = $Heartbeat

var reading_dialog: bool = false
var dialog = [
	"meu casca de bala, você cometeu um erro",
	"manoel afton estava jogando xadrez 4d e você não percebeu",
	"ele me matill e plantou provas falsas na pará lanches",
	"o bill nunca fez nada. ele só tinha o mindset diferente do manoel",
	"enquanto a lá ele lanches nunca saiu do interior da bahia,\na pará lanches virou uma franquia nacional",
	"o único crime de bill foi ter as mesmas 24 horas que o manoel\ne trabalhar enquanto ele dormia",
	"testemunhas relataram ver um homem azulado na cena dos crimes,\ne agora o stitiliro está sob custódia",
	"quando você tacou fogo na pará lanches,\ntodas as prillvas foram destruilldas",
	"você é a sua própria consequillcia.\nbill está morto, manoel está solto e você foi moggado"
]

func _ready() -> void:
	_67_sprite.visible = false
	dialog_text.visible = false
	
	await get_tree().create_timer(2.5).timeout
	
	fire.stop()
	bill_sprite.visible = false
	_67_sprite.visible = true
	
	await get_tree().create_timer(1).timeout
	
	heartbeat.play()
	reading_dialog = true
	dialog_text.visible = true
	dialog_text.text = dialog.pop_front()

func _input(event: InputEvent) -> void:
	if !reading_dialog:
		return
	
	if event.is_action_pressed("next"):
		var text = dialog.pop_front() # remove o prímeiro índice e segue pro próximo
		if text:
			dialog_text.text = text
		else:
			dialog_text.text = "acbaou fim"
			success.play()
			await success.finished
			SceneManager.to_menu()
