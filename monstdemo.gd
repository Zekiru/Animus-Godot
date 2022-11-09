extends KinematicBody2D

onready var player = get_node("/root/leveldemo/player1demo")

var rng = RandomNumberGenerator.new()

export var speed = 400.00
var velocity : Vector2
var last_player_pos = Vector2.ZERO
var rotation_dir = rng.randf()

var player_in_range = false
var player_in_sight = false
var player_was_seen = false

func _ready():
	$AnimatedSprite.play()

func _on_LoadTime_timeout():
	# Calculate the position of the player relative to the skeleton
	var player_relative_position = player.position - position
	
#	if player_relative_position.length() <= 50:
#		# If player is near, don't move but turn toward it
#		velocity = Vector2.ZERO
#		last_player_pos = player_relative_position.normalized()
#	elif player_relative_position.length() <= 800: #and bounce_countdown == 0:
#		# If player is within range, move toward it
#		velocity = player_relative_position.normalized() * speed
#	if busy == 0:
		# If player is too far, randomly decide whether to stand still or where to move
	
	if player_was_seen == false:
		var random_number = rng.randf()
		if random_number < 0.6:
			velocity = Vector2.ZERO
		elif random_number < 0.9 and $MoveTime.time_left == 0:
			rotation_dir = rng.randf()
			$MoveTime.wait_time = rng.randf()
			$MoveTime.start()
			

func _process(delta):
	if $MoveTime.time_left > 0:
		if rotation_dir < 0.5:
			$sight.rotation += 0.01
		else:
			$sight.rotation -= 0.01
		velocity = Vector2.RIGHT.rotated($sight.rotation) * speed

func _physics_process(delta):
	var movement = velocity * delta
	var collision = move_and_slide(velocity)
	
	SightCheck()


func _on_sight_body_entered(body):
	if body == player:
		player_in_range = true
#		print("in range: ", player_in_range)


func _on_sight_body_exited(body):
	if body == player:
		player_in_range = false
#		print("in range: ", player_in_range)

func SightCheck():
	var player_relative_position = player.position - position
	
	if player_in_range == true:
		var space_state = get_world_2d().direct_space_state
		var sight_check = space_state.intersect_ray(position, player.position, [self], collision_mask)
		if sight_check:
			if sight_check.collider.name == "player1demo":
				player_in_sight = true
				player_was_seen = true
#				print("in sight: ", player_in_sight)
				speed = 600
				$sight.look_at(player.position)
				velocity = player_relative_position.normalized() * speed
				last_player_pos = player.position
#				print(player.position)
			else:
				player_in_sight = false
#				print("in sight: ", player_in_sight)
				if player_was_seen == true:
					$sight.look_at(last_player_pos)
				if player_was_seen == true and $LastSeenTime.time_left == 0:
					$LastSeenTime.start()
					yield($LastSeenTime, "timeout")
					player_was_seen = false
				else:
					speed = 400
