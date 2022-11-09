extends Node2D

var in_window = true
onready var normal_zoom = Vector2(3, 3)
export var to_destination = Vector2.ZERO

func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_MOUSE_EXIT:
			in_window = false
		MainLoop.NOTIFICATION_WM_MOUSE_ENTER:
			in_window = true

func _ready():
	$responsivecam.current = true
	$responsivecam.zoom = normal_zoom

func _process(_delta):
	mouse_on_window()
	
	lerp_parentcam()


func mouse_on_window():
	var _mouse = get_viewport().get_mouse_position()
	
	if in_window: #mouse != Vector2(0, 0):
#		$responsivecam.position = (mouse - Vector2(1280/2, 720/2)) / 2
#		$responsivecam.position = lerp($responsivecam.position, (mouse - Vector2(1280/2, 720/2)) / 2, 0.2)
		pass

func lerp_parentcam():
#	position = to_player
	position = lerp(position, to_destination, 0.05)
