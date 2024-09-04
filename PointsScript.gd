extends CharacterBody2D
enum Directions{Left,Right}

var Direction = Directions.Left
var Speed : float = 0

func _ready():
	Speed = randf_range(100,250)
	var Height = 900 - randf() * 650.0
	#PDF = 650x + 250
	#PDF 900 - 650x^2
	if Direction == Directions.Left:
		position.x = randi_range(1970,1995)
	elif Direction == Directions.Right:
		position.x = randi_range(-75,-50)
	position.y = Height
	pass

func _physics_process(delta: float) -> void:
	if Direction == Directions.Left:
		velocity = Vector2(-Speed,0)
	elif Direction == Directions.Right:
		velocity = Vector2(Speed,0)
	OutOfBounds()
	move_and_slide()

func OutOfBounds():
	if (position.x < -25 and Direction == Directions.Left) or (position.x > 1945 and Direction == Directions.Right):
		queue_free()

func _Collected():
	queue_free()
