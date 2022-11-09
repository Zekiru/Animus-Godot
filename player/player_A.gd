extends KinematicBody2D

export var normal_speed = 800
export var dash_speed = 2000
export var crouch_speed = 500
var speed = normal_speed
var velocity = Vector2.ZERO
var input_velocity = Vector2.ZERO
export var normal_accel = 60
export var normal_deccel = 60
var accel = normal_accel
var deccel = normal_deccel

var can_flashlight = false
var flash_light = false

export var take_damage = true
export var max_health = 100
var health = max_health

var sneaking = false
var sliding = false

var dashing = false
var can_dash = true
export var max_stamina = 100
var stamina = max_stamina
export var stamina_consump = 50

var can_move = true

var ability_disabled = false
var ability_active = false
var ability_inuse = false
var ability_cooldown = false

onready var anim = $AnimatedSprite
var normal_animspeed = 1.8
var sneaking_animspeed = 1.2

onready var current_level
onready var enemybody = get_tree().get_nodes_in_group("enemy")

var rng = RandomNumberGenerator.new()

var state_machine

func _ready():
	current_level = $"../../../"
	if current_level != null and current_level.get_node_or_null("spawnpos") != null:
		position = current_level.get_node("spawnpos").position
	
	$AnimatedSprite.speed_scale = normal_animspeed
	
	state_machine = $AnimationTree.get("parameters/playback")

func get_movement():
#	velocity = Vector2.ZERO
	input_velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_velocity.x += 1
	if Input.is_action_pressed("move_left"):
		input_velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		input_velocity.y += 1
	if Input.is_action_pressed("move_up"):
		input_velocity.y -= 1

	input_velocity = input_velocity.normalized() * speed

func _input(_event):
	if Input.is_action_just_pressed("space"):
		dash()
	
	if Input.is_action_pressed("shift"):
		sneakorslide()
	
	if Input.is_action_just_released("shift"):
		sneakorslide_release()
	
	
	if Input.is_action_just_pressed("ability"):
		if ability_disabled == false:
			if ability_active:
				ability_active = false
			else:
				ability_active = true
			ability()


func _process(_delta):
	if health < 0:
		health = 0
	if stamina < 0:
		stamina = 0
	if health == 0:
		queue_free()
	
	
	if dashing:
		pass
	if dashing == false:
		pass
	if sneaking:
		pass
	if sliding:
		while_sliding()
	
	
	sprite_anim()
	
	if ability_active:
		anim.modulate = lerp(anim.modulate, Color(0.27, 0.27, 0.27, 0.7), 0.05)
	else:
		anim.modulate = lerp(anim.modulate, Color(1, 1, 1, 1), 0.05)


func _physics_process(_delta):
	if can_move:
		get_movement()
		
		if input_velocity.length() > 0:
			velocity.x = move_toward(velocity.x, input_velocity.x, accel) #velocity.linear_interpolate(input_velocity, 0.2)
			velocity.y = move_toward(velocity.y, input_velocity.y, accel)
		else:
			velocity.x = move_toward(velocity.x, 0, deccel) #velocity.linear_interpolate(Vector2.ZERO, 0.2)
			velocity.y = move_toward(velocity.y, 0, deccel)
		
		velocity = move_and_slide(velocity)
	else:
		velocity = Vector2.ZERO


func _on_hitbox_area_entered(area):
	if take_damage:
		if area.name == "enemy_hitbox":
			take_damage1()

func _on_DamageTimer_timeout():
		take_damage1()

func take_damage1():
	if health > 0:
		health -= 1
	$DamageTimer.start()
	$HealthCooldown.start()
	$HealthRegen.stop()

func _on_hitbox_area_exited(area):
	if area.name == "enemy_hitbox":
		$DamageTimer.stop()


func _on_HealthCooldown_timeout():
	$HealthRegen.start()

func _on_HealthRegen_timeout():
	if health < 100:
		health += 0.05
	else:
		$HealthRegen.stop()


func sprite_anim():
	if can_move:
		if velocity.length() > 0:
			play_anim(true)
		elif velocity.length() == 0:
			play_anim(false)
	
	if velocity.x != 0 and velocity.y == 0:
		if velocity.x < 0:
			state_machine.travel("left")
		else:
			state_machine.travel("right")
	elif velocity.y != 0 and velocity.x == 0:
		if velocity.y > 0:
			state_machine.travel("down")
		else:
			state_machine.travel("up")
	elif velocity.x && velocity.y != 0:
		if velocity.y > 0:
			if velocity.x < 0:
				state_machine.travel("downleft")
			else:
				state_machine.travel("downright")
		else:
			if velocity.x < 0:
				state_machine.travel("upleft")
			else:
				state_machine.travel("upright")


func dash():
	if can_dash and stamina >= stamina_consump and velocity != Vector2.ZERO:
		dashing = true
		can_dash = false
		stamina -= stamina_consump
		speed = dash_speed
		accel = speed
		anim.frame = 1
		anim.stop()
		$hitbox/hitboxshape.disabled = true
		$Dash_Length.start()
		$Dash_Cooldown.start()

func _on_Dash_Length_timeout():
	dashing = false
	if sliding == true:
		speed = dash_speed
	elif ability_active:
		play_anim(false)
		speed = normal_speed
		accel = normal_accel
		$hitbox/hitboxshape.disabled = false
	else:
		speed = normal_speed
		accel = normal_accel
		play_anim(true)
		$hitbox/hitboxshape.disabled = false
	

func _on_Dash_Cooldown_timeout():
	can_dash = true

func _on_Stamina_Regen_timeout():
	if stamina < max_stamina:
		stamina += 0.1


func sneakorslide():
	if dashing:
		sliding = true
		$hitbox/hitboxshape.disabled = false
	
	if dashing == false:
		sneaking = true
		speed = crouch_speed
		anim.speed_scale = sneaking_animspeed
		$hitbox/hitboxshape.disabled = false

func while_sliding():
	accel = speed
	anim.frame = 1
	if speed > normal_speed:
		speed = move_toward(speed, normal_speed, 7)
	elif speed <= normal_speed:
		accel = normal_accel
		if Input.is_action_pressed("shift"):
			speed = crouch_speed
		else:
			speed = normal_speed
		sliding = false

func sneakorslide_release():
	if sliding:
		sliding = false
		speed = normal_speed
		accel = normal_accel
		anim.speed_scale = normal_animspeed
		$hitbox/hitboxshape.disabled = false
	
	if sneaking:
		sneaking = false
		speed = normal_speed
		accel = normal_accel
		anim.speed_scale = normal_animspeed
		$hitbox/hitboxshape.disabled = false



func turn_to(direction):
	if direction == "up":
		state_machine.travel("up")
	if direction == "upleft":
		state_machine.travel("upleft")
	if direction == "left":
		state_machine.travel("left")
	if direction == "downleft":
		state_machine.travel("downleft")
	if direction == "down":
		state_machine.travel("down")
	if direction == "downright":
		state_machine.travel("downright")
	if direction == "right":
		state_machine.travel("right")
	if direction == "upright":
		state_machine.travel("upright")

func play_anim(status):
	if status == true:
		anim.play()
	else:
		anim.frame = 0
		anim.stop()



func ability():
	if  ability_active:
		play_anim(false)
		can_move = false
		
		$walkarea.disabled = true
		$hitbox/hitboxshape.disabled = true
		
		if ability_inuse == false:
			ability_inuse = true
			$Ability_Length.start()
	else:
		$Ability_Length.stop()
		ability_inuse = false
		can_move = true
		
		$walkarea.disabled = false
		$hitbox/hitboxshape.disabled = false

func _on_Ability_Length_timeout():
	ability_active = false
	ability()
