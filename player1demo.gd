extends KinematicBody2D

export var speed = 900.0
var velocity = Vector2.ZERO

export var max_health = 20
var health = 20
signal health_change(health)

var can_dash = true
export var max_stamina = 50
var stamina = 50
signal stamina_change(stamina)


func _ready():
	emit_signal("health_change", health)
	emit_signal("stamina_change", stamina)
	$Dash_Cooldown.start()

func get_input():
	velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
#	Make sure diagonal movement isn't faster

	velocity = velocity.normalized() * speed

func _input(event):
	pass

func _process(delta):
	$flashlightcont.look_at(get_global_mouse_position())
	
	if can_dash and stamina >= 10 and velocity != Vector2.ZERO and Input.is_action_just_pressed("space"):
		dash()
		can_dash = false
		$Dash_Cooldown.start()
	
	if velocity.length() > 0:
		velocity = velocity.normalized()
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.frame = 0
		$AnimatedSprite.stop()
	
	
	if velocity.x && velocity.y != 0:
		if velocity.y > 0:
			$AnimatedSprite.animation = "downright"
		elif velocity.y < 0:
			$AnimatedSprite.animation = "upright"
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.x != 0:
		$AnimatedSprite.animation = "right"
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		if velocity.y > 0:
			$AnimatedSprite.animation = "down"
		else:
			$AnimatedSprite.animation = "up"


func _physics_process(delta):
	get_input()
	position += velocity * delta
	
	move_and_slide(velocity * delta)

#func _on_hitbox_body_entered(body):
#	if health > 0:
#		health -= 2
#	emit_signal("health_change", health)
#	$DamageTimer.start()
#	$HealthCooldown.start()
#	$HealthRegen.stop()
#	pass
#
#func _on_DamageTimer_timeout():
#	if health > 0:
#		health -= 2
#	emit_signal("health_change", health)
#	$DamageTimer.start()
#	$HealthCooldown.start()
#	$HealthRegen.stop()
#	pass
#
#func _on_hitbox_body_exited(body):
#	$DamageTimer.stop()
#	pass

func _on_HealthCooldown_timeout():
	$HealthRegen.start()

func _on_HealthRegen_timeout():
	if health < 20:
		health += 1
		emit_signal("health_change", health)
	else:
		$HealthRegen.stop()


func dash():
	stamina -= 10
	$Dash_Length.start()
	$AnimatedSprite.frame = 1
	speed *= 3
	$hitbox/hitboxshape.disabled = true
	yield($Dash_Length, "timeout")
	$AnimatedSprite.play()
	speed /= 3
	$hitbox/hitboxshape.disabled = false

func _on_Dash_Cooldown_timeout():
	can_dash = true

func _on_Stamina_Regen_timeout():
	emit_signal("stamina_change", stamina)
	if stamina < max_stamina:
		stamina += 1
