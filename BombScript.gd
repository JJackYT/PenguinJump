extends CharacterBody2D

enum Directions{Left,Right}
enum State{Default,Hit}


var Direction = Directions.Left
var Speed : float = 0

var BombState : State = State.Default

@export var Particles : GPUParticles2D 
@export var BombTexture : TextureRect

func _ready():
	Speed = randf_range(100,250)
	var Height = randf_range(500,800)
	if Direction == Directions.Left:
		position.x = randi_range(1970,1995)
	elif Direction == Directions.Right:
		scale.x = -1
		position.x = randi_range(-75,-50)
	position.y = Height
	pass

func _physics_process(delta: float) -> void:
	
	if Direction == Directions.Left:
		velocity = Vector2(-Speed,0)
	elif Direction == Directions.Right:
		velocity = Vector2(Speed,0)
	OutOfBounds()
	
	if BombState == State.Default:
		move_and_slide()
	else:
		#TODO Explosion
		pass

func OutOfBounds():
	if (position.x < -25 and Direction == Directions.Left) or (position.x > 1945 and Direction == Directions.Right):
		queue_free()

func Hit():
	Particles.emitting = true
	BombTexture.visible = false
	collision_layer = 0
	BombState = State.Hit
	get_tree().create_timer(1).timeout.connect(queue_free)
