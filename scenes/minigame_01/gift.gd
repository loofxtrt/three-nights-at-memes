extends Area2D

@export var manager: Node

func _on_body_entered(body: Node2D) -> void:
	manager.increase_points()
	queue_free()
