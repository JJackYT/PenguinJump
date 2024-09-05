extends Node2D
@export_category("Gameplay")
@export var Player : Node2D
@export var Floor : Node2D
@export var ProjectileCollections : Node2D

var Max_Lives : int = 3
var Lives : int = 3

var Start_Sink_Speed : float = 150.0
var Sink_Speed : float = 150.0

var Floor_Time : int = 0
var Air_Time : int = 0
var Total_Time : int = 0

var Points : int = 0

var BombChance : float = 0.1

var ProjectileCooldown : int = 0
var ProjectileRate : int = 20

var Started : bool = false
var GameOver : bool = false

var Combo : int = 0

var HighScore : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_AudioReady()
	Player.CollectedPoint.connect(CollectedPoints)
	Player.GotHit.connect(PlayerHit)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Floor.position.y = move_toward(Floor.position.y, 800 + (300 * Floor_Time / Sink_Speed) ,2)
	_UI_process(delta)
	_AudioProcess(delta)
	pass
	
func _physics_process(delta: float) -> void:
	if Started and not GameOver:
		Total_Time += 1
		Projectiles()
		Calc_Times(delta)
	else:
		Floor_Time = 0
		Sink_Speed = Start_Sink_Speed
		Air_Time = 0
		Total_Time = 0
		Points = 0
		if Input.is_action_just_pressed("Jump") and GameOver:
			SetGameOver(false)
			Floor.collision_layer = 1
			Player.Restart()
			Lives = Max_Lives
			RemoveProjectiles()
		elif Input.is_action_just_pressed("Jump"):
			StartGame()
	
func Calc_Times(delta : float):
	if Sink_Speed > 30:
		Sink_Speed -= delta / 2
	if Player.is_on_floor():
		Air_Time = 0
		Floor_Time += 1
		Combo = 0
		if Floor_Time > Sink_Speed:
			SetGameOver(true)
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
	if Gen_Chance < Get_Bomb_Chance():
		New_Projectile = preload("res://Bomb.tscn").instantiate()
	else:
		New_Projectile = preload("res://Points.tscn").instantiate()
	var Direction_Chance = randf()
	if Direction_Chance > 0.5:
		New_Projectile.Direction = New_Projectile.Directions.Right
	ProjectileCollections.add_child(New_Projectile)

func Get_Bomb_Chance():
	if Total_Time > 4 * 30 * 60:
		return BombChance + 0.4
	else:
		return BombChance + Total_Time / (30.0 * 600.0)
	return BombChance

func PlayerHit():
	if Lives > 0:
		Lives -= 1
	if Lives == 0:
		SetGameOver(true)
		Floor.collision_layer = 0

func CollectedPoints():
	Points += CalculatePointWorth()
	Combo += 1

func CalculatePointWorth():
	return round((100 * 2 ** floor(Total_Time / (60.0 * 60.0)) * (1.5 ** Combo))/10)

func SetGameOver(value: bool):
	GameOver = value
	Player.GameOver = value
	if value:
		if Points > HighScore:
			HighScore = Points
		Player.Started = false
		Started = false

func StartGame():
	Player.Started = true
	Started = true

func RemoveProjectiles():
	var ProjectilesLeft = ProjectileCollections.get_children()
	while ProjectilesLeft.size() > 0:
		ProjectilesLeft[0].queue_free()
		ProjectilesLeft.remove_at(0)


#UI Control
@export_category("UI")

@export var Time_Keeper : Label
@export var Point_Keeper : Label
@export var GameOver_Label : Label
@export var StartGame_Label : Label
@export var HighScore_Label : Label

@export var IceBergTexture : ColorRect
@export var IceBergAnim : AnimatedSprite2D

func _UI_process(_delta : float)-> void:
	var Seconds = floor((Total_Time / 60) % 60)
	var Minutes = floor((Total_Time / 60 - Seconds) / 60)
	SetIceBergTexture()
	Time_Keeper.text = "%s:%s" % [Minutes,str(Seconds).lpad(2,"0")]
	HighScore_Label.text = "HIGHSCORE: %s" % HighScore
	Point_Keeper.text = str(Points)
	GameOver_Label.visible = GameOver
	StartGame_Label.visible = not Started and not GameOver
	pass

func SetIceBergTexture():
	IceBergAnim.frame = Lives
	#IceBergTexture.size.x = 100 * (2 ** Lives) if Lives > 0 else 0
	#IceBergTexture.position.x = - IceBergTexture.size.x / 2

#Audio Control
@export_category("Audio")
@export var AudioPlayer : AudioStreamPlayer
func _AudioReady():
	AudioPlayer.play()
	
func _AudioProcess(delta : float):
	pass
