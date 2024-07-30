extends CharacterBody2D


const SPEED = 50.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var looking_front = true
var looking_up = false
var looking_down = false

var sprite_size = 16

var damping = 0.9
var hitted_by_enemy = false

func __looking_front():
	looking_front = true
	looking_up = false
	looking_down = false

func __looking_up():
	looking_front = false
	looking_up = true
	looking_down = false

func __looking_down():
	looking_front = false
	looking_up = false
	looking_down = true

func _physics_process(delta):
	# Add the gravity.
	#if not is_on_floor():
		#velocity.y += gravity * delta
		
	if hitted_by_enemy == true:
		velocity *= damping
		# Stop the enemy completely if the velocity is very small
		if velocity.length() < 1:
			velocity = Vector2.ZERO
			hitted_by_enemy = false
			self.rotate(90)
	else:
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept"):
			get_node("AnimationPlayer").play("strong_sword_attack")
			#if looking_front:
				#get_node("AnimationPlayer").play("sword_attack_front")
			#if looking_up:
				#get_node("AnimationPlayer").play("sword_attack_up")
			#if looking_down:
				#get_node("AnimationPlayer").play("sword_attack_down")
	#
		## Get the input direction and handle the movement/deceleration.
		## As good practice, you should replace UI actions with custom gameplay actions.
		var direction
		if Input.is_action_pressed("ui_right"):
			__looking_front()
			direction = Vector2(1, 0)
			get_node("Sprite2D").scale.x = 1
			#get_node("Sprite2D/SwordSprite2D").flip_h = false
			#get_node("Sprite2D/ShieldSprite2D").flip_h = false
			if Input.is_action_pressed("ui_up"):
				direction = Vector2(1, -1)
			if Input.is_action_pressed("ui_down"):
				direction = Vector2(1, 1)
		if Input.is_action_pressed("ui_left"):
			__looking_front()
			get_node("Sprite2D").scale.x = -1
			#get_node("Sprite2D/SwordSprite2D").flip_h = true
			#get_node("Sprite2D/ShieldSprite2D").flip_h = true
			direction = Vector2(-1, 0)
			if Input.is_action_pressed("ui_up"):
				direction = Vector2(-1, -1)
			if Input.is_action_pressed("ui_down"):
				direction = Vector2(-1, 1)
		if Input.is_action_pressed("ui_up"):
			__looking_up()
			direction = Vector2(0, -1)
			if Input.is_action_pressed("ui_right"):
				direction = Vector2(1, -1)
			if Input.is_action_pressed("ui_left"):
				direction = Vector2(-1, -1)
		if Input.is_action_pressed("ui_down"):
			__looking_down()
			direction = Vector2(0, 1)
			if Input.is_action_pressed("ui_right"):
				direction = Vector2(1, 1)
			if Input.is_action_pressed("ui_left"):
				direction = Vector2(-1, 1)
		#var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity = direction * SPEED
		else:
			velocity = Vector2.ZERO

	move_and_slide()

func _on_damage_area_2d_body_entered(body):
	print("Player hitted by ", body.name)
	if body.name == "Enemy":
		hitted_by_enemy = true
		var direction = self.global_position - body.global_position
		direction = direction.normalized()
		var push_strength = 300  # Adjust the strength of the push
		velocity += direction * push_strength
		self.rotate(-90)
