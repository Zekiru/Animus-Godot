extends Node2D

onready var player = get_node("/root/leveldemo/player1demo")


func _ready():
	pass

func _process(delta):
	var mouse = get_viewport().get_mouse_position()
	position = player.position

	
	if mouse != Vector2(0, 0):
		$responsivecam.position = (mouse - Vector2(1280/2, 720/2)) / 2
	else:
		$responsivecam.position = player.position


func _on_player1demo_stamina_change(stamina):
	$StaminaBar.set_value(stamina)

func _on_player1demo_health_change(health):
	$HealthBar.set_value(health)
