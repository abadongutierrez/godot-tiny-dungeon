extends CharacterBody2D

@export var knockback_resistance: float = 1
var knockback = Vector2.ZERO
var damping = 0.9
var hitted_by_player = false

@onready var player = get_node("/root/Main/Player")

func _ready():
	get_node("Line2D").add_point(Vector2(0,0))
	get_node("Line2D").add_point(self.velocity)

func _physics_process(delta):
	var new_pos = Vector2(self.velocity)
	new_pos.normalized()
	#get_node("Line2D").set_point_position(1, self.global_position)
	get_node("Line2D").set_point_position(0, new_pos)
	
	# your normal direction/velocity calculation here
	# after you have your final velocity value, you just need to add knockback vector to it
	# move_toward will reduce knockback vector each frame/call by resistance amount, i.e. bring knockback to a stop
	#knockback = knockback.move_toward(Vector2.ZERO, knockback_resistance)
	#velocity += knockback * delta
	# global_position += velocity
	if hitted_by_player == true:
		velocity *= damping
		# Stop the enemy completely if the velocity is very small
		if velocity.length() < 1:
			velocity = Vector2.ZERO
			self.queue_free()
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
		
func _on_area_2d_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	print("area.name=", area.name)
	if area.name == "PlayerSwordArea2D":
		hitted_by_player = true
		# direction_to returns a normalized vector, i.e. < 1 pixel, so you want to multiply that by how far you want enemy to be knocked back
		#knockback = player.global_position.direction_to(global_position) * 10
		#self.queue_free()
		var direction = self.global_position - player.global_position
		direction = direction.normalized()
		var push_strength = 300  # Adjust the strength of the push
		velocity += direction * push_strength
	elif area.name == "PlayerDamageArea2D":
		player.hitted_by(self)
	else:
		hitted_by_player = false
