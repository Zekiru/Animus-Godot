extends KinematicBody2D

onready var current_level = get_node_or_null("../../")

onready var player_parent
onready var player
var player_present

var respawned = false

var can_move = true
var can_rotate = true
var can_chase = true
var canmove_afterchase = true

onready var start_pos = position
var start_rot = 0

var rng = RandomNumberGenerator.new()
var random1
var random2
var rand1
var rand2

export var normal_speed = 400
export var chase_speed = 900
var speed = 400
var velocity = Vector2.ZERO
var input_velocity = Vector2.ZERO
export var normal_accel = 60
export var normal_deccel = 60
var accel = normal_accel
var deccel = normal_deccel
var last_player_pos = Vector2.ZERO

#var sight_check

var player_in_range = false
var player_in_sight = false
var player_is_seen = false
var player_was_seen = false

var smooth_rotate
var rotate_to = 0
var rotate_to_player

var chasing = false
var is_near_range = false
var is_near = false
var near = false

var is_stunned = false

onready var anim = $AnimatedSprite

func _ready():
	randomize()
	
	$sight/lightsight.show()
	$Light2D.show()


func get_player():
	if current_level != null:
		player_parent = current_level.get_node_or_null("level_kinematics/player")
		if player_parent != null:
			if player_parent.get_child_count() > 0:
				player = player_parent.get_child(0)
				player_present = true
			else:
				player_present = false
			respawn()


func _process(_delta):
	get_player()
	get_playerstatus()
	
	smooth_rotate = fmod(lerp_angle($sight.global_rotation, rotate_to, 0.2), TAU)
	rotate_to_player = fmod((last_player_pos - global_position).normalized().angle(), TAU)
	
	idle_mode()
	
	if is_instance_valid(player):
		sneak_check()
	
	$sight.global_rotation = smooth_rotate
	
	
	sprite_anim()
	
	if is_stunned:
		anim.modulate = lerp(anim.modulate, Color(1, 0.27, 0.27), 0.1)
		player_in_sight = false
		player_is_seen = false
		player_was_seen = false
		can_move = false
		can_rotate = false
		can_chase = false
		input_velocity = Vector2.ZERO
	else:
		anim.modulate = lerp(anim.modulate, Color(1, 1, 1), 0.05)


func _physics_process(_delta):
	
	SightCheck()
	
	
	if input_velocity.length() > 0:
		velocity.x = move_toward(velocity.x, input_velocity.x, accel)
		velocity.y = move_toward(velocity.y, input_velocity.y, accel)
	else:
		velocity.x = move_toward(velocity.x, 0, deccel)
		velocity.y = move_toward(velocity.y, 0, deccel)
	
	velocity = move_and_slide(velocity)


func get_playerstatus():
	if current_level != null:
		if player_is_seen:
			get_tree().call_group("enemy", "chasing_player", true)
			chasing = true
		elif chasing:
			get_tree().call_group("enemy", "chasing_player", false)
			chasing = false
		
		if is_near:
			get_tree().call_group("enemy", "near_player", true)
			near = true
		elif near:
			get_tree().call_group("enemy", "near_player", false)
			near = false

func chasing_player(status):
	if status == true:
		current_level.chasing_player = true
	else:
		current_level.chasing_player = false

func near_player(status):
	if status == true:
		current_level.near_player = true
	else:
		current_level.near_player = false

func sprite_anim():
	if can_move:
		if velocity.length() > 0:
			play_anim(true)
		elif velocity.length() == 0:
			play_anim(false)
	
	if $sight.global_rotation >= 0:
		if $sight.global_rotation < PI / 8:
			anim.animation = "right"
		elif $sight.global_rotation < 3 * PI / 8:
			anim.animation = "downright"
		elif $sight.global_rotation < 5 * PI / 8:
			anim.animation = "down"
		elif $sight.global_rotation < 7 * PI / 8:
			anim.animation = "downright"
		else:
			anim.animation = "right"
		anim.flip_h = $sight.global_rotation > PI / 2
	else:
		if $sight.global_rotation > -PI / 8:
			anim.animation = "right"
		elif $sight.global_rotation > -3 * PI / 8:
			anim.animation = "upright"
		elif $sight.global_rotation > -5 * PI / 8:
			anim.animation = "up"
		elif $sight.global_rotation > -7 * PI / 8:
			anim.animation = "upright"
		else:
			anim.animation = "right"
		anim.flip_h = $sight.global_rotation < -PI / 2


func respawn():
	if player_present:
		respawned = false
	elif player_present == false and respawned == false:
		respawned = true
		yield(current_level.get_node("deathtimer"), "timeout")
		position = start_pos
		$sight.rotation = fmod(start_rot, TAU)


func sneak_check():
	if player_was_seen:
		$sight/radial_sight.disabled = false
	else:
		if player.speed == player.crouch_speed or player.velocity == Vector2.ZERO:
			$sight/radial_sight.disabled = true
		else:
			$sight/radial_sight.disabled = false


func _on_LoadTime_timeout():
	if player_was_seen == false or is_instance_valid(player) == false:
		if can_move == false or random1 == null:
			input_velocity = Vector2.ZERO
		if random1 != null:
			rand1 = random1
			if rand1 < 0.7:
				input_velocity = Vector2.ZERO
			elif rand1 < 1 and $MoveTime.time_left == 0:
				if random2 != null:
					rand2 = random2
					$MoveTime.wait_time = rng.randf()
					$MoveTime.start()

func idle_mode():
	if $MoveTime.time_left > 0:
		if can_rotate:
			if rand2 < 0.6:
				rotate_to = fmod(rng.randf() * 0.1 + $sight.global_rotation, TAU)
			else:
				rotate_to = fmod(-rng.randf() * 0.1 + $sight.global_rotation, TAU)
		if can_move:
			input_velocity = Vector2.RIGHT.rotated($sight.global_rotation).normalized() * speed


func _on_near_range_body_entered(body):
	if is_instance_valid(player):
		if body == player:
			is_near_range = true


func _on_near_range_body_exited(body):
	if is_instance_valid(player):
		if body == player:
			is_near_range = false
			is_near = false


func _on_sight_body_entered(body):
	if is_instance_valid(player):
		if body == player:
			player_in_range = true

func _on_sight_body_exited(body):
	if is_instance_valid(player):
		if body == player:
			player_in_range = false

func SightCheck():
	if is_near_range:
		var space_state = get_world_2d().direct_space_state
		var sight_check = space_state.intersect_ray(position, player.position, [self], $near_range.collision_mask)
		if sight_check:
			if sight_check.collider.name == player.name:
				is_near = true
			else:
				is_near = false
	
	if player_in_range:
		var space_state = get_world_2d().direct_space_state
		var sight_check = space_state.intersect_ray(position, player.position, [self], $sight.collision_mask)
		if sight_check:
			if sight_check.collider.name == player.name:
				player_in_sight = true
				player_is_seen = true
				player_was_seen = true
			else:
				player_in_sight = false
				
	
	if player_in_range == false:
		player_in_sight = false
	
	if player_in_sight:
		speed = chase_speed
		last_player_pos = player.position
		if can_rotate:
			rotate_to = rotate_to_player
		if can_chase:
			input_velocity = Vector2.RIGHT.rotated($sight.rotation).normalized() * speed
		if canmove_afterchase:
			can_move = true
	
	if player_in_sight == false:
		if player_is_seen:
			if can_rotate:
				rotate_to = rotate_to_player
			$LastSeenTime.start()
			player_is_seen = false
			yield($LastSeenTime, "timeout")
			player_was_seen = false
		
		if player_was_seen == false:
			speed = normal_speed


func stunned():
	if player_in_range:
		is_stunned = true
		$Stun_Timer.start()
		yield($Stun_Timer, "timeout")
		is_stunned = false
		can_rotate = true
		can_chase = true


func turn_to(direction):
	if direction == "up":
		rotate_to = 3 * PI / 2
	if direction == "upleft":
		rotate_to = 5 * PI / 4
	if direction == "left":
		rotate_to = PI
	if direction == "downleft":
		rotate_to = 3 * PI / 4
	if direction == "down":
		rotate_to = PI / 2
	if direction == "downright":
		rotate_to = PI / 4
	if direction == "right":
		rotate_to = 0
	if direction == "upright":
		rotate_to = 7 * PI / 4

func play_anim(status):
	if status == true:
		anim.play()
	else:
		anim.frame = 0
		anim.stop()
