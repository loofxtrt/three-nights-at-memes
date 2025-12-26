extends Node

@onready var amostradinho_warning: AudioStreamPlayer = $AmostradinhoWarning
@onready var amostradinho_running: AudioStreamPlayer = $AmostradinhoRunning
@onready var amostradinho_knocking: AudioStreamPlayer = $AmostradinhoKnocking
@onready var jumpscare: AudioStreamPlayer = $Jumpscare
@onready var door_slam: AudioStreamPlayer = $DoorSlam
@onready var light_flicker: AudioStreamPlayer = $LightFlicker
@onready var ambience: AudioStreamPlayer = $Ambience
@onready var going_away: AudioStreamPlayer = $GoingAway
@onready var animatronic_in_office: AudioStreamPlayer = $AnimatronicInOffice
@onready var breathing: AudioStreamPlayer = $Breathing
@onready var mask_on: AudioStreamPlayer = $MaskOn
@onready var mask_off: AudioStreamPlayer = $MaskOff

# esse em específico não funciona pelo audiocontroller por algum motivo
#@onready var camera_switch: AudioStreamPlayer = $CameraSwitch

# uso:
# NomeDoAutoload.nome_da_variavel.play()

func _ready() -> void:
	# abaixar o áudio de todos os streams igualmente
	for c in get_children():
		if c is AudioStreamPlayer:
			c.volume_db = -10
	
	ambience.play()
