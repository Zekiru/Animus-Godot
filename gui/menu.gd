extends CanvasLayer

signal start_pressed
signal quit_pressed
signal pause_pressed
signal resume_pressed

var loaded = false

onready var char_selected = "char1"
onready var viewchar = $"mainmenu/menuselect/selectionbox/selection/charview/AnimatedSprite"

onready var current_scene = $"../CurrentScene"
onready var current_level
onready var player_parent
onready var player
var player_present = false
var game_started1 = false
var game_started2 = false

onready var health = $HUD/bottomhud/bars/HealthBar
onready var stamina = $HUD/bottomhud/bars/StaminaBar

onready var textbox1 = $mainmenu/menuselect/descriptionbox/textbox1
onready var textbox2 = $mainmenu/menuselect/descriptionbox/textbox2
onready var textbox3 = $mainmenu/menuselect/descriptionbox/textbox3

var hud_state
var leveltitle_state
var dialouge_state

func _ready():
	hud_state = $HUDanimtree.get("parameters/playback")
	leveltitle_state = $HUD/Title/AnimationTree.get("parameters/playback")
	dialouge_state = $HUD/dialouge/AnimationTree.get("parameters/playback")
	
	$mainmenu.show()
	$HUD.hide()
	
	textbox2.hide()
	textbox3.hide()


func get_player():
	if current_scene != null:
		if current_scene.get_child_count() > 0:
			current_level = current_scene.get_child(0)
			player_parent = current_level.get_node("level_kinematics/player")
			if player_parent.get_child_count() > 0:
				player = player_parent.get_child(0)
				player_present = true
			else:
				player_present = false
		else:
			player_present = false


func hud_status():
	if player_present:
		health.value = player.health
		stamina.value = player.stamina


func _process(_delta):
	get_player()
	hud_status()
	run_active()
	
	if is_instance_valid(current_level):
		if current_level != null:
			if current_level.name == "level1":
				level1anim()
			if current_level.name == "level2":
				level2anim()


func _on_Play_pressed():
	$AnimationPlayer.play("menuselect_slidein")

func _on_Back_pressed():
	$AnimationPlayer.play("menuselect_slideout")

func _on_Start_pressed():
	emit_signal("start_pressed")

func _on_Quit_pressed():
	emit_signal("quit_pressed")

func _on_pause_pressed():
	emit_signal("pause_pressed")

func _on_Resume_pressed():
	emit_signal("resume_pressed")



func _on_leftselect_pressed():
	if char_selected == "char1":
		show_char3()
	elif char_selected == "char3":
		show_char2()
	else:
		show_char1()


func _on_rightselect_pressed():
	if char_selected == "char1":
		show_char2()
	elif char_selected == "char2":
		show_char3()
	else:
		show_char1()

func show_char1():
	char_selected = "char1"
	viewchar.animation = "char1"
	textbox1.show()
	textbox2.hide()
	textbox3.hide()

func show_char2():
	char_selected = "char2"
	viewchar.animation = "char2"
	textbox1.hide()
	textbox2.show()
	textbox3.hide()

func show_char3():
	char_selected = "char3"
	viewchar.animation = "char3"
	textbox1.hide()
	textbox2.hide()
	textbox3.show()

var level1scene2 = false
var level1_1key = false
var level1_allkeys = false

func level1anim():
	if current_level.has_1key == false:
		level1_1key = false
	if current_level.has_allkeys == false:
		level1_allkeys = false
	
	
	if game_started1 == false:
		game_started1 = true
		leveltitle_state.travel("level1")
		dialouge_state.travel("level1_started")
	
	if level1scene2 == false and current_level.cutscene2:
		level1scene2 = true
		dialouge_state.travel("level1_scene2")
	
	if level1_1key == false and current_level.has_1key:
		level1_1key = true
		dialouge_state.travel("level1_1key")
	
	if level1_allkeys == false and current_level.has_allkeys:
		level1_allkeys = true
		dialouge_state.travel("level1_allkeys")
	
	if current_level.has_1key:
		if current_level.has_allkeys:
			$HUD/bottomhud/equipped/AnimationPlayer.play("key_ab")
		else:
			if current_level.key_A_obtained:
				$HUD/bottomhud/equipped/AnimationPlayer.play("key_A")
			if current_level.key_B_obtained:
				$HUD/bottomhud/equipped/AnimationPlayer.play("key_b")
	else:
		$HUD/bottomhud/equipped/AnimationPlayer.play("none")
			
	if current_level.door_is_locked != null:
		if current_level.door_is_unlocked:
			current_level.door_is_unlocked = false
			dialouge_state.travel("ok_that_should_do_it")
		elif current_level.door_is_locked:
			if current_level.has_1key:
				current_level.door_is_locked = false
				dialouge_state.travel("one_more_keypart")
			else:
				current_level.door_is_locked = false
				dialouge_state.travel("its_locked")

func level2anim():
	if game_started2 == false:
		game_started2 = true
		leveltitle_state.travel("level2")


func run_active():
	if current_level != null:
		if current_level.chasing_player:
			hud_state.travel("hud_run")
		else:
			if current_level.near_player:
				hud_state.travel("hud_beware")
			else:
				hud_state.travel("hud_idle")
