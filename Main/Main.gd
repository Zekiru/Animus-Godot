extends Node

var start_cutscene = false
var in_game = false
var paused = false
var queing = false

var quit = false
var to_level1 = false
var to_level2 = false

var char_selected

onready var current_level
onready var player_parent
onready var player
var player_present

var hud_show = false
var hud_hide = true

var respawned = false

var playerdemo = preload("res://demo/playerdemo.tscn")
var leveldemo = preload("res://demo/leveldemo.tscn")
#var level1 = preload("res://level//level1.tscn")
#var level2 = preload("res://level//level2.tscn")


func _ready():
	queing = true
	start_cutscene = true
	$DarkModulate.hide()
	$transitionscreen/AnimationPlayer.play("fade_to_normal_0.5x")
	$menu/bg.hide()
	$menu/mainmenu.hide()
	yield($startup_cutscene/Timer, "timeout")
	$transitionscreen.transition()

func _input(_event):
	if Input.is_action_just_pressed("escape"):
		pause_menu()


func get_player():
	if $CurrentScene.get_child_count() > 0:
		current_level = $CurrentScene.get_child(0)
		current_level.char_selected = char_selected
		player_parent = current_level.get_node("level_kinematics/player")
		in_game = true
		if player_parent.get_child_count() > 0:
			player = player_parent.get_child(0)
			player_present = true
		else:
			player_present = false

func _process(_delta):
	get_player()
	hud_toggle()
	
	if Input.is_action_just_pressed("ui_up"):
		get_tree().reload_current_scene()
	
	if get_node_or_null("startup_cutscene") == null:
		$DarkModulate.show()
	
	if start_cutscene:
		if Input.is_action_just_pressed("enter") or Input.is_action_just_pressed("space"):
			$transitionscreen.transition()
	
	if is_instance_valid(current_level):
		if current_level.dead:
			if respawned == false:
				respawned = true
				$transitionscreen/AnimationPlayer.play("respawn")
		else:
			respawned = false
	
	if in_game and current_level.next_level == true:
		current_level.next_level = false
		if queing == false:
			queing = true
			$transitionscreen.transition()


func change_level():
	if $CurrentScene.get_child_count() == 0:
		var level1 = preload("res://level//level1.tscn")
		$CurrentScene.add_child(level1.instance())
	elif $CurrentScene.get_child(0).name == "level1":
		var level2 = preload("res://level//level2.tscn")
		$CurrentScene.get_child(0).queue_free()
		$CurrentScene.add_child(level2.instance())
	else:
		get_tree().quit()


func _on_menu_quit_pressed():
	if queing == false:
		queing = true
		quit = true
		$transitionscreen.transition()

func _on_menu_start_pressed():
	if queing == false:
		queing = true
		to_level1 = true
		char_selected = $menu.char_selected
		$transitionscreen.transition()

func _on_menu_pause_pressed():
	pause_menu()

func _on_menu_resume_pressed():
	pause_menu()


func _on_transitionscreen_transitioned():
	if start_cutscene:
		start_cutscene = false
		$startup_cutscene.queue_free()
		$menu/bg.show()
		$menu/mainmenu.show()
	elif quit:
		quit = false
		get_tree().quit()
	elif to_level1:
		#to_level1 = false
		change_level()
		$menu/mainmenu.hide()
		$menu/bg.hide()
		$menu/HUD.show()
	else:
		change_level()
	
	queing = false


func pause_menu():
	if player_present and queing == false:
		queing = true
		if paused:
			paused = false
			$menu/menu2.hide()
			$menu/HUD.show()
			get_tree().paused = false
	#		$CurrentScene.show()
		elif paused == false:
			paused = true
			$menu/menu2.show()
			$menu/HUD.hide()
			get_tree().paused = true
	#		$CurrentScene.hide()
		queing = false

func hud_toggle():
	if player_present:
		if hud_show == false:
			hud_show = true
			hud_hide = false
			$menu/HUD.show()
	else:
		if hud_hide == false:
			hud_hide = true
			hud_show = false
			$menu/HUD.hide()
