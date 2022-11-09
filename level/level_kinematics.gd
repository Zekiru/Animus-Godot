extends YSort

var rng = RandomNumberGenerator.new()

var random_array1 = [rng.randf(), rng.randf()]
var random_array2 = [rng.randf(), rng.randf()]
var random_array3 = [rng.randf(), rng.randf()]
var random_array4 = [rng.randf(), rng.randf()]
var random_array5 = [rng.randf(), rng.randf()]
var random_array6 = [rng.randf(), rng.randf()]

onready var enemy1 = get_node_or_null("enemy_A")
onready var enemy2 = get_node_or_null("enemy_A2")
onready var enemy3 = get_node_or_null("enemy_A3")
onready var enemy4 = get_node_or_null("enemy_A4")
onready var enemy5 = get_node_or_null("enemy_A5")
onready var enemy6 = get_node_or_null("enemy_A6")

onready var enemy = get_tree().get_nodes_in_group("enemy")

onready var chasing_player = false

func _ready():
	randomize()
	
	set_group_rules()

func _process(_delta):
	random_array1 = [rng.randf(), rng.randf()]
	random_array2 = [rng.randf(), rng.randf()]
	random_array3 = [rng.randf(), rng.randf()]
	random_array4 = [rng.randf(), rng.randf()]
	random_array5 = [rng.randf(), rng.randf()]
	random_array6 = [rng.randf(), rng.randf()]
	
	if is_instance_valid(enemy1):
		enemy1.random1 = random_array1[0]
		enemy1.random2 = random_array1[1]
	if is_instance_valid(enemy2):
		enemy2.random1 = random_array2[0]
		enemy2.random2 = random_array2[1]
	if is_instance_valid(enemy3):
		enemy3.random1 = random_array2[0]
		enemy3.random2 = random_array2[1]
	if is_instance_valid(enemy4):
		enemy4.random1 = random_array2[0]
		enemy4.random2 = random_array2[1]
	if is_instance_valid(enemy5):
		enemy5.random1 = random_array2[0]
		enemy5.random2 = random_array2[1]
	if is_instance_valid(enemy6):
		enemy6.random1 = random_array2[0]
		enemy6.random2 = random_array2[1]


func set_group_rules():
	get_tree().set_group("enemy", "can_move", false)
	get_tree().set_group("enemy", "can_rotate", true)
	get_tree().set_group("enemy", "can_chase", true)
	get_tree().set_group("enemy", "canmove_afterchase", true)
