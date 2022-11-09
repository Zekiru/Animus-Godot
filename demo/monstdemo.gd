extends KinematicBody2D

#onready var player = get_node("/root/leveldemo/player1demo")
onready var player = get_node("../../player1demo")

var loaded = false

var can_move = true
var can_rotate = true
var start_rotation

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

var sight_check

var player_in_range = false
var player_in_sight = false
var player_is_seen = false
var player_was_seen = false

var smooth_rotate
var rotate_to = 0
var rotate_to_player

func _ready():
	randomize()

func _on_LoadTime_timeout():
#	if player_relative_position.length() <= 50:
#		velocity = Vector2.ZERO
#		last_player_pos = player_relative_position.normalized()
#	elif player_relative_position.length() <= 800: #and bounce_countdown == 0:
#		velocity = player_relative_position.normalized() * speed
	
#	if player_in_range == false:
#		player_was_seen = false
	
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

func _process(delta):
	loading()
	
	smooth_rotate = fmod(lerp_angle($sight.global_rotation, rotate_to, 0.2), TAU)
	rotate_to_player = fmod((last_player_pos - global_position).normalized().angle(), TAU)
	
	if $MoveTime.time_left > 0:
		if can_rotate:
			if rand2 < 0.6:
				rotate_to = fmod(rng.randf() * 0.1 + $sight.global_rotation, TAU)
			else:
				rotate_to = fmod(-rng.randf() * 0.1 + $sight.global_rotation, TAU)
		if can_move:
			input_velocity = Vector2.RIGHT.rotated($sight.global_rotation) * speed
	
#	if player_was_seen == false:
#		$sight.rotation = rotate_idle
	
	if is_instance_valid(player):
		if player_was_seen:
			$sight/CollisionShape2D2.disabled = false
		else:
			if player.speed == player.crouch_speed or player.velocity == Vector2.ZERO:
				$sight/CollisionShape2D2.disabled = true
			else:
				$sight/CollisionShape2D2.disabled = false
	
	$sight.global_rotation = smooth_rotate
	
#	print($sight.rotation_degrees)
	
	if velocity.length() > 0:
		$AnimatedSprite.play()
	elif velocity.length() == 0:
		$AnimatedSprite.frame = 0
		$AnimatedSprite.stop()
	
#	if velocity.x && velocity.y != 0:
#		if velocity.y > 0:
#			$AnimatedSprite.animation = "downright"
#		elif velocity.y < 0:
#			$AnimatedSprite.animation = "upright"
#		$AnimatedSprite.flip_h = velocity.x < 0
#	if $sight.rotation < 1:
#		$AnimatedSprite.animation = "down"
#		$AnimatedSprite.flip_h = velocity.x < 0
#
#	elif velocity.y != 0:
#		if velocity.y > 0:
#			$AnimatedSprite.animation = "down"
#		else:
#			$AnimatedSprite.animation = "up"
	
	if $sight.global_rotation >= 0:
		if $sight.global_rotation < PI / 8:
			$AnimatedSprite.animation = "right"
		elif $sight.global_rotation < 3 * PI / 8:
			$AnimatedSprite.animation = "downright"
		elif $sight.global_rotation < 5 * PI / 8:
			$AnimatedSprite.animation = "down"
		elif $sight.global_rotation < 7 * PI / 8:
			$AnimatedSprite.animation = "downright"
		else:
			$AnimatedSprite.animation = "right"
		$AnimatedSprite.flip_h = $sight.global_rotation > PI / 2
	else:
		if $sight.global_rotation > -PI / 8:
			$AnimatedSprite.animation = "right"
		elif $sight.global_rotation > -3 * PI / 8:
			$AnimatedSprite.animation = "upright"
		elif $sight.global_rotation > -5 * PI / 8:
			$AnimatedSprite.animation = "up"
		elif $sight.global_rotation > -7 * PI / 8:
			$AnimatedSprite.animation = "upright"
		else:
			$AnimatedSprite.animation = "right"
		$AnimatedSprite.flip_h = $sight.global_rotation < -PI / 2

func loading():
	if loaded == false:
		if start_rotation != null:
			$sight.rotation = start_rotation
		loaded = true

func _physics_process(delta):
#	var collision = move_and_slide(velocity)
	
	SightCheck()
	
	if input_velocity.length() > 0:
		velocity.x = move_toward(velocity.x, input_velocity.x, accel) #velocity.linear_interpolate(input_velocity, 0.2)
		velocity.y = move_toward(velocity.y, input_velocity.y, accel)
	else:
		velocity.x = move_toward(velocity.x, 0, deccel) #velocity.linear_interpolate(Vector2.ZERO, 0.2)
		velocity.y = move_toward(velocity.y, 0, deccel)
	
	velocity = move_and_slide(velocity)


func _on_sight_body_entered(body):
	if is_instance_valid(player):
		if body == player:
			player_in_range = true
	#		print("in range: ", player_in_range)


func _on_sight_body_exited(body):
	if is_instance_valid(player):
		if body == player:
			player_in_range = false
	#		print("in range: ", player_in_range)

func SightCheck():
	if player_in_range:
		var space_state = get_world_2d().direct_space_state
		sight_check = space_state.intersect_ray(position, player.position, [self], $sight.collision_mask)
		if sight_check:
			if sight_check.collider.name == "player1demo":
				player_in_sight = true
				player_is_seen = true
				player_was_seen = true
			else:
				player_in_sight = false
#				print("in sight: ", player_in_sight)
				
	
	if player_in_range == false: #$sight.look_at(last_player_pos)	if player_in_range == false:
		player_in_sight = false
	
	if player_in_sight:
		speed = chase_speed
		last_player_pos = player.position
		rotate_to = rotate_to_player
		if can_move:
			input_velocity = Vector2.RIGHT.rotated($sight.rotation) * speed
	
	if player_in_sight == false:
		if player_is_seen:
			rotate_to = rotate_to_player #$sight.look_at(last_player_pos)
			$LastSeenTime.start()
			player_is_seen = false
			yield($LastSeenTime, "timeout")
			player_was_seen = false
		
		if player_was_seen == false:
			speed = normal_speed


#	if player_in_sight == false and player_was_seen:
#		$sight.look_at(last_player_pos)
#		$LastSeenTime.start()
#		print(player_was_seen)
#	if $LastSeenTime.time_left == 0:
#		player_was_seen = false
#		print(player_was_seen)
