extends CharacterBody2D

signal CollectedPoint()
signal GotHit()

const GRAVITY = Vector2(0,980)
const JUMP_VELOCITY = -600.0
var JUMP_CHARGE = 0
var MAX_CHARGE = 100

@export var PointCollector : Area2D
@export var BombCollector : Area2D

var on_floor : bool = false
var Started : bool = false
var GameOver : bool = false

func _ready():
	pass

func _process(delta:float):
	if is_on_floor():
		scale.x = JUMP_CHARGE / 500.0 + 1.0
		scale.y = 1.0 - JUMP_CHARGE / 500.0 
	elif velocity.y < 0:
		scale.x = 1.0 - abs(velocity.y) / 3000.0 
		scale.y = abs(velocity.y) / 3000.0 + 1.0
	else:
		scale.move_toward(Vector2(1,1),0.2)
		

func _physics_process(delta: float) -> void:
	if position.y > 1080:
		GotHit.emit()
	# Add the gravity.
	if not is_on_floor():
		velocity += GRAVITY * delta

	# Handle jump.
	if not GameOver and Started:
		if is_on_floor():
			CheckJump()
	else:
		JUMP_CHARGE = 0
	move_and_slide()

func CheckJump():
	if Input.is_action_pressed("Jump"):
		JUMP_CHARGE += 1
		if JUMP_CHARGE >= MAX_CHARGE:
			Jump()
	else:
		if JUMP_CHARGE > 0:
			Jump()

func Jump():
	velocity.y = -JUMP_CHARGE * 8 + JUMP_VELOCITY
	JUMP_CHARGE = 0
	pass

func hit_floor(body):
	on_floor = true
	
func unhit_floor(body):
	on_floor = false
	
func CollectPoint(Point):
	Point._Collected()
	CollectedPoint.emit()

func BombHit(Bomb):
	Bomb.Hit()
	GotHit.emit()

func Restart():
	position = Vector2(960,700)
	velocity.y = 0
