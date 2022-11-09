extends Area2D

onready var current_level = $"../"
onready var player_parent
onready var player

var in_range = false

signal key_taken
onready var existing = true

onready var state_machine = $AnimationTree.get("parameters/playback")


func _ready():
	pass
#	$AnimationPlayer.play("pulsating")

func get_player():
	if current_level != null:
		player_parent = current_level.get_node("level_kinematics/player")
		if player_parent != null:
			if player_parent.get_child_count() > 0:
				player = player_parent.get_child(0)

func _process(_delta):
	get_player()
	
	if in_range:
		if Input.is_action_just_pressed("interact"):
			emit_signal("key_taken")
			hide()
			existing = false
	
	if existing:
		show()
		$pick_area.disabled = false
	else:
		hide()
		$pick_area.disabled = true

func _on_Key_A_body_entered(body):
	if body == player:
		state_machine.travel("nearby")
		in_range = true


func _on_Key_A_body_exited(body):
	if body == player:
		state_machine.travel("pulsating")
		in_range = false
