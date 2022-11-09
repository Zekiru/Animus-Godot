extends Node2D

var cam_to_playerA = false
var cam_to_playerB = false
var cam_to_playerC = false
var cam_to_enemyA = false

func _ready():
	$AnimationPlayer.play("cutscene_playing")
	
	$player_A.ability_disabled = true
	$player_C.ability_disabled = true
	
	$player_A.can_move = false
	$player_A.take_damage = false
	$player_B.can_move = false
	$player_B.take_damage = false
	$player_C.can_move = false
	$player_C.take_damage = false
	
	$enemy_A.can_move = false

func _process(_delta):
	$CanvasModulate.show()
	
	if cam_to_playerA:
		$levelcam.to_destination = $player_A.position
	if cam_to_playerB:
		$levelcam.to_destination = $player_B.position
	if cam_to_playerC:
		$levelcam.to_destination = $player_C.position
	if cam_to_enemyA:
		$levelcam.to_destination = $enemy_A.position


func cam_destination(name):
	if name == "player_A":
		cam_to_playerA = true
		cam_to_playerB = false
		cam_to_playerC = false
		cam_to_enemyA = false
	elif name == "player_B":
		cam_to_playerA = false
		cam_to_playerB = true
		cam_to_playerC = false
		cam_to_enemyA = false
	elif name == "player_C":
		cam_to_playerA = false
		cam_to_playerB = false
		cam_to_playerC = true
		cam_to_enemyA = false
	elif name == "enemy_A":
		cam_to_playerA = false
		cam_to_playerB = false
		cam_to_playerC = false
		cam_to_enemyA = true
