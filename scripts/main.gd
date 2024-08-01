extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = Timer.new()
	timer.wait_time = 5
	timer.one_shot = false
	timer.connect("timeout", __spawn_enemy)
	add_child(timer)
	timer.start()
	
func __spawn_enemy():
	#print("New enemy!")
	var enemy = preload("res://scenes/enemy.tscn")
	var new_enemy = enemy.instantiate()
	new_enemy.name = "Enemy"
	var rng = RandomNumberGenerator.new()
	new_enemy.position = Vector2(rng.randi_range(500, 100), rng.randi_range(300, 500))
	get_node("Node").add_child(new_enemy)

