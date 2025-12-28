extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite

const SPEED = 300
var direction: Vector2

func _physics_process(delta: float) -> void:
	direction.x = Input.get_axis("left", "right")
	direction.y = Input.get_axis("top", "down")
	
	direction = direction.normalized() # corrigir velocidade angular/diagonal
	
	if direction.x > 0: 
		sprite.flip_h = true
	elif direction.x < 0: # em vez de else pq se não toda vez que para de andar, flipa
		sprite.flip_h = false
	
	if direction:
		# andar
		velocity = direction * SPEED
	else:
		# parar de andar
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	
	move_and_slide()
