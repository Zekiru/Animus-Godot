extends Node2D

var rng = RandomNumberGenerator.new()
var random1_1 = rng.randf()
var random1_2 = rng.randf()
var random2_1 = rng.randf()
var random2_2 = rng.randf()
var random3_1 = rng.randf()
var random3_2 = rng.randf()

func _ready():
	randomize()
#	$monstdemo.can_move = false
#	$monstdemo.can_rotate = false

func _process(_delta):
	$player1demo.can_flashlight = false
	random1_1 = rng.randf()
	random1_2 = rng.randf()
	random2_1 = rng.randf()
	random2_2 = rng.randf()
	random3_1 = rng.randf()
	random3_2 = rng.randf()
#	$monstdemo1/monstdemo.random1 = random1_1
#	$monstdemo1/monstdemo.random2 = random1_2
#	$monstdemo1/monstdemo2.random1 = random2_1
#	$monstdemo1/monstdemo2.random2 = random2_2
#	$monstdemo1/monstdemo3.random1 = random3_1
#	$monstdemo1/monstdemo3.random2 = random3_2
