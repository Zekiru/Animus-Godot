extends KinematicBody2D

export var normal_speed = 2000 #800
export var dash_speed = 4000 #2000
export var crouch_speed = 1000 #500
var speed = normal_speed
var velocity = Vector2.ZERO
var input_velocity = Vector2.ZERO
export var normal_accel = 500 #60
export var normal_deccel = 500 #60
var accel = normal_accel
var deccel = normal_deccel

var can_flashlight = false
var flash_light = false

export var max_health = 100
var health = max_health

var sneaking = false
var sliding = false

var dashing = false
var can_dash = true
export var max_stamina = 100
var stamina = max_stamina
export var stamina_consump = 0 #25

var can_move = true

onready var anim = $AnimatedSprite
var normal_animspeed = 1.5 * 2
var sneaking_animspeed = 1 * 2

onready var current_level
onready var enemybody = get_tree().get_nodes_in_group("enemy")

var rng = RandomNumberGenerator.new()

func _ready():
	current_level = $"../../../"
	if current_level != null:
		position = current_level.get_node("spawnpos").position

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
	
	
#	if Input.is_action_just_pressed("right_click"):
#		get_tree().paused = true
#		print("time-stopped")
	
#	if Input.is_action_just_released("right_click"):
#		get_tree().paused = false
#		print("time-resumed")
	
	
#	if Input.is_action_just_pressed("left_click"):
#		if flash_light:
#			flash_light = false
#		elif flash_light == false:
#			flash_light = true



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


func _on_hitbox_area_entered(_area):
	take_damage1()

func _on_DamageTimer_timeout():
	take_damage1()

func take_damage1():
	if health > 0:
		health -= 1
	$DamageTimer.start()
	$HealthCooldown.start()
	$HealthRegen.stop()

func _on_hitbox_area_exited(_area):
	$DamageTimer.stop()


func _on_HealthCooldown_timeout():
	$HealthRegen.start()

func _on_HealthRegen_timeout():
	if health < 100:
		health += 0.05
	else:
		$HealthRegen.stop()


func sprite_anim():
	if velocity.length() > 0:
		anim.play()
	elif velocity.length() == 0:
		anim.frame = 0
		anim.stop()
	
	if velocity.x != 0 and velocity.y == 0:
		anim.animation = "right"
		anim.flip_h = velocity.x < 0
	elif velocity.y != 0 and velocity.x == 0:
		if velocity.y > 0:
			anim.animation = "down"
		else:
			anim.animation = "up"
	elif velocity.x && velocity.y != 0:
		if velocity.y > 0:
			anim.animation = "downright"
		elif velocity.y < 0:
			anim.animation = "upright"
		anim.flip_h = velocity.x < 0


func dash():
	if can_dash and stamina >= stamina_consump and velocity != Vector2.ZERO:
		dashing = true
		can_dash = false
		stamina -= stamina_consump
		speed = dash_speed
		accel = speed
		anim.frame = 1
		$hitbox/hitboxshape.disabled = true
		$Dash_Length.start()
		$Dash_Cooldown.start()

func _on_Dash_Length_timeout():
	dashing = false
	if sliding == true:
		speed = dash_speed
	else:
		speed = normal_speed
		accel = normal_accel
		anim.play()
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
