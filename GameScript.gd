extends Node2D

@export var Player : Node2D
@export var Floor : Node2D
@export var ProjectileCollections : Node2D

var Lives : int = 3

var Sink_Speed : float = 100.0

var GameOver : bool = false
var Floor_Time : int = 0
var Air_Time : int = 0
var Total_Time : int = 0

var Points : int = 0

var BombChance : float = 0.1

var ProjectileCooldown : int = 0
var ProjectileRate : int = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player.CollectedPoint.connect(CollectedPoints)
	Player.GotHit.connect(PlayerHit)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	Floor.position.y = move_toward(Floor.position.y, 800 + (200 * Floor_Time / Sink_Speed) ,2)
	_UI_process(delta)
	pass
	
func _physics_process(delta: float) -> void:
	Total_Time += 1
	Projectiles()
	Calc_Times(delta)
	
func Calc_Times(delta : float):
	if Sink_Speed > 30:
		Sink_Speed -= delta / 2
	if Player.is_on_floor():
		Air_Time = 0
		Floor_Time += 1
		if Floor_Time > Sink_Speed:
			GameOver = true
	else:
		Air_Time += 1
		if Air_Time > 10:
			Floor_Time = move_toward(Floor_Time,0,delta * 5)

func Projectiles():
	ProjectileCooldown += 1
	if ProjectileCooldown > ProjectileRate:
		ProjectileCooldown = 0
		SpawnProjectile()

func SpawnProjectile():
	var New_Projectile 
	var Gen_Chance = randf()
	if Gen_Chance < BombChance:
		New_Projectile = preload("res://Bomb.tscn").instantiate()
	else:
		New_Projectile = preload("res://Points.tscn").instantiate()
	var Direction_Chance = randf()
	if Direction_Chance > 0.5:
		New_Projectile.Direction = New_Projectile.Directions.Right
	ProjectileCollections.add_child(New_Projectile)

func PlayerHit():
	Lives -= 1
	if Lives == 0:
		GameOver = true

func CollectedPoints():
	Points += 100
#UI Control
@export var Time_Keeper : Label
@export var Point_Keeper : Label

func _UI_process(delta : float)-> void:
	var Seconds = floor((Total_Time / 60) % 60)
	var Minutes = floor((Total_Time / 60 - Seconds) / 60)
	Time_Keeper.text = "%s:%s" % [Minutes,str(Seconds).lpad(2,"0")]
	Point_Keeper.text = str(Points)
	pass
