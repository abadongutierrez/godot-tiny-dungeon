extends CharacterBody2D

@export var knockback_resistance: float = 1
var knockback = Vector2.ZERO
var damping = 0.9
var speed = 100
var hitted_by_player = false

var api_key = ""
var api_url = "https://api.openai.com/v1/engines/davinci-codex/completions"

@onready var player = get_node("/root/Main/Player")

func _ready():
	var decision = make_decision(get_game_state())

func get_game_state():
	var state = {
		"enemy_position": position,
		"player_position": player.position,
		"enemy_health": 100,
		"player_health": 100,
		"distance_to_player": position.distance_to(player.position)
	}
	return JSON.stringify(state)

func make_decision(state):
	var http = HTTPClient.new()
	http.connect_to_host("api.openai.com", 443)

	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		OS.delay_msec(10)

	if http.get_status() != HTTPClient.STATUS_CONNECTED:
		print("Unable to connect to OpenAI API")
		return null

	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + api_key
	]
	
	var request_body = {
		"prompt": "Decide if the enemy should attack based on the following game state: " + state,
		"max_tokens": 5,
		"temperature": 0.5
	}
	
	http.request_raw(HTTPClient.METHOD_POST, api_url, headers, JSON.stringify(request_body).to_utf8_buffer())
	
	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		OS.delay_msec(10)

	if http.get_status() == HTTPClient.STATUS_BODY:
		var response = http.read_response_body_chunk()
		var json = JSON.new()
		var result = json.parse(response.get_string_from_utf8())
		print("response=", response, ", result=", result)
		#if result != null && result["choices"] != null && result["choices"][0] != null && result["choices"][0]["text"] != null:
			#return result["choices"][0]["text"].strip_edges()
	
	return null


func _physics_process(delta):
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
	move_and_slide()

func attack_player():
	# Implement the attack logic
	print("Attacking player")
	velocity = (player.position - position).normalized() * speed
	move_and_slide()

func idle_state():
	# Implement idle behavior
	print("Idling")
	velocity = Vector2.ZERO
	move_and_slide()

func _on_area_2d_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	print(area.name)
	if area.name == "PlayerSwordArea2D":
		hitted_by_player = true
		# direction_to returns a normalized vector, i.e. < 1 pixel, so you want to multiply that by how far you want enemy to be knocked back
		#knockback = player.global_position.direction_to(global_position) * 10
		#self.queue_free()
		var direction = self.global_position - player.global_position
		direction = direction.normalized()
		var push_strength = 300  # Adjust the strength of the push
		velocity += direction * push_strength
