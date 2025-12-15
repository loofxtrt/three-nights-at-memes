extends Node

var is_cameras_open: bool = false
var power: float = 100.0

var luva_pos = "stage"
var virginia_pos = "stage"
var bill_pos = "stage"
var amostradinho_stage: int = 1

func modify_power(amount: float):
	power += amount
	print("energia atual: " + str(power))
