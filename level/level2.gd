extends Node2D

onready var started = false

onready var player_parent = $level_kinematics/player
onready var player
onready var cam = $levelcam
onready var responsive_cam = $levelcam/responsivecam
onready var normal_zoom = $levelcam.normal_zoom
var cam_free = false

var player1demo = preload("res://demo/playerdemo.tscn")
var player_A = preload("res://player/player_A.tscn")
var player_B = preload("res://player/player_B.tscn")
var player_C = preload("res://player/player_C.tscn")

var char_chosen = false
onready var char_selected

var player_pos = Vector2.ZERO
var death_cam = Vector2.ZERO
var in_window = true
onready var dead = false

onready var chasing_player = false
onready var near_player = false

export var cutscene_disabled = false
export var playtest = false

var cutscene2 = false

var key_A_obtained = false
var key_B_obtained = false
var door_is_locked = false
var door_is_unlocked = false
var has_1key = false
var has_allkeys = false

var next_level = false


func _ready():
	started = true
	
	$levelcam/responsivecam.current = true
	cam.position = $spawnpos.position
	$playersight.position = $spawnpos.position

func _process(_delta):
	if playtest:
		if char_chosen == false:
			char_chosen = true
			char_selected = null
			spawn_player()
			cutscene_disabled = true
	elif char_selected != null:
		if char_chosen == false:
			char_chosen = true
			spawn_player()
	
	if char_chosen:
		if is_instance_valid(player):
			player_alive()
		else:
			player_dead()

func spawn_player():
	if char_selected == "char1":
		player_parent.add_child(player_A.instance())
	elif char_selected == "char2":
		player_parent.add_child(player_B.instance())
	elif char_selected == "char3":
		player_parent.add_child(player_C.instance())
	else:
		player_parent.add_child(player1demo.instance())
	
	player = player_parent.get_child(0)

func player_alive():
#	$levelcam/responsivecam/HUD/hudbox.show()
#	$levelcam.health = player.health
#	$levelcam.stamina = player.stamina
	
	player_pos = player.global_position
#	cam.global_position = lerp(cam.global_position, player_pos, 0.02)
	if cam_free == false:
		cam.to_destination = player_pos
	death_cam = cam.global_position
	$playersight.global_position = player_pos

func player_dead():
#	$levelcam/responsivecam/HUD/hudbox.hide()
	
	cam.global_position = death_cam
	death_cam = lerp(death_cam, player_pos, 0.01)
	responsive_cam.zoom = lerp(responsive_cam.zoom, Vector2(4, 4), 0.01)
	
	if dead == false:
		dead = true
		$deathtimer.start()

func _on_deathtimer_timeout():
	dead = false
	spawn_player()
	$level_kinematics.set_group_rules()
	cam.position = $spawnpos.position
	$playersight.position = $spawnpos.position
	responsive_cam.zoom = normal_zoom
	
	get_tree().set_group("door", "closed", true)


func _on_next_level_body_entered(body):
	if body == player:
		next_level = true
