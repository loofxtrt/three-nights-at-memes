extends Node

var is_cameras_open: bool = false
var power: float = 100.0

func modify_power(amount: float):
	power += amount
	print("energia atual: " + str(power))
