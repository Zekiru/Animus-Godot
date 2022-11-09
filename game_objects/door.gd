extends StaticBody2D

onready var state_machine
onready var current_level = $"../../"
var player_parent
var player

var door_open = false
var accessable = false
var clickable = false

var closed = false
var locked = false

signal door_is_locked

func _ready():
	state_machine = $AnimationTree.get("parameters/playback")

func get_player():
	if is_instance_valid(current_level):
		player_parent = current_level.get_node("level_kinematics/player")
		if player_parent != null:
			if player_parent.get_child_count() > 0:
				player = player_parent.get_child(0)

func _process(_delta):
	get_player()
	
	if accessable:
		modulate = lerp(modulate, Color(3, 3, 3), 0.05)
		if Input.is_action_just_pressed("interact"):
			if locked == false:
				if door_open:
					state_machine.travel("closed")
					door_open = false
				else:
					state_machine.travel("open")
					door_open = true
			else:
				emit_signal("door_is_locked")
	else:
			modulate = lerp(modulate, Color(1, 1, 1), 0.05)
	
	if closed == true:
		closed = false
		state_machine.travel("closed")
		door_open = false


func _on_accessarea_body_entered(body):
	if body == player:
		accessable = true


func _on_accessarea_body_exited(body):
	if body == player:
		accessable = false
