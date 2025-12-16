extends Node

@onready var amostradinho_warning: AudioStreamPlayer = $AmostradinhoWarning
@onready var amostradinho_running: AudioStreamPlayer = $AmostradinhoRunning
@onready var amostradinho_knocking: AudioStreamPlayer = $AmostradinhoKnocking
@onready var jumpscare: AudioStreamPlayer = $Jumpscare

# uso:
# NomeDoAutoload.nome_da_variavel.play()

func _ready() -> void:
	# abaixar o áudio de todos os streams igualmente
	for c in get_children():
		if c is AudioStreamPlayer:
			c.volume_db = -10
