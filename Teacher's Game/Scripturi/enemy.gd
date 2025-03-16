extends CharacterBody2D

var Speed = 20
var health = 100
@onready var animated_sprite_2d = $AnimatedSprite2D
var original_color = Color(1, 1, 1, 1)
var hit_color = Color(1, 0, 0, 1)
@onready var color = $color
var moveDirection = Vector2.ZERO
@onready var healthbar = $healthbar
@onready var animation_player = $AnimationPlayer
@onready var player = $"../player"
@export var MoveSpeed: float = 20.0
var lastPosition = Vector2(0, 1)
@onready var detection = $detection
@onready var player_hitbox = get_node("/root/world/player/player_hitbox")
@onready var enemy_icon = $"../player/CanvasLayer/healthbar_enemy/enemy_icon"
@onready var healthbar_enemy = $"../player/CanvasLayer/healthbar_enemy"
var interact = false
@export var target: Node2D = null
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
var waypoints = []
var current_waypoint = 0
@onready var timer: Timer = $Timer
var waiting = false
var at_destination = false  

func _ready():
	healthbar_enemy.value = 0
	add_to_group("enemy_hitbox")
	call_deferred("seeker_setup")


	for area in get_tree().get_nodes_in_group("loc"):
		waypoints.append(area.global_position)

	# Alege un waypoint care nu este ocupat
	if waypoints.size() > 0:
		var found_waypoint = false
		var start_index = randi() % waypoints.size()  
		current_waypoint = start_index

		while !found_waypoint:
			if !WaypointManager.is_waypoint_occupied(waypoints[current_waypoint]):
				found_waypoint = true
			else:
				current_waypoint += 1
				if current_waypoint >= waypoints.size():
					current_waypoint = 0  
				if current_waypoint == start_index:
					print("Toate waypoint-urile sunt ocupate la start!")
					return 

		WaypointManager.occupy_waypoint(waypoints[current_waypoint], self)
		navigation_agent_2d.set_target_position(waypoints[current_waypoint])

func _physics_process(_delta):
	if waypoints.is_empty() or waiting:
		return


	if !at_destination and navigation_agent_2d.is_navigation_finished():
		at_destination = true
		waiting = true
		animated_sprite_2d.play("idle")
		timer.start()
		return

	if at_destination:
		if !navigation_agent_2d.is_navigation_finished():
			at_destination = false  

	var next_path_position = navigation_agent_2d.get_next_path_position()
	var direction = (next_path_position - global_position).normalized()
	velocity = direction * Speed
	move_and_slide()
	movement()

func seeker_setup():
	await get_tree().physics_frame
	if target:
		navigation_agent_2d.target_position = target.global_position

func select_new_direction():
	var random = RandomNumberGenerator.new()
	moveDirection = Vector2(
		random.randi_range(-1, 1),
		random.randi_range(-1, 1)
	).normalized()

func movement():
	if velocity != Vector2.ZERO:
		if abs(velocity.x) > abs(velocity.y):
			# Dacă mișcarea pe axa X este dominantă
			if velocity.x < 0:
				animated_sprite_2d.play("walk-stanga")
				lastPosition = Vector2(-1, 0)
			else:
				animated_sprite_2d.play("walk-dreapta")
				lastPosition = Vector2(1, 0)
		else:
			# Dacă mișcarea pe axa Y este dominantă
			if velocity.y < 0:
				animated_sprite_2d.play("walk-sus")
				lastPosition = Vector2(0, -1)
			else:
				animated_sprite_2d.play("walk-jos")
				lastPosition = Vector2(0, 1)
	else:
		animated_sprite_2d.play("idle")

func _on_color_timeout():
	animated_sprite_2d.modulate = original_color

func _on_change_direction_timeout():
	select_new_direction()

func _input(event):
	if Input.is_action_just_pressed("interact") and interact:
		moveDirection = Vector2.ZERO
		animated_sprite_2d.play("idle")

func _on_atack_zone_body_entered(body: Node2D) -> void:
	interact = true

func _on_atack_zone_body_exited(body: Node2D) -> void:
	interact = false

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	pass

func _on_timer_timeout() -> void:
	waiting = false

	if WaypointManager.is_waypoint_occupied(waypoints[current_waypoint]):
		WaypointManager.release_waypoint(waypoints[current_waypoint])

	var found_waypoint = false
	var start_index = current_waypoint  
	while !found_waypoint:
		current_waypoint += 1
		if current_waypoint >= waypoints.size():
			current_waypoint = 0

		if !WaypointManager.is_waypoint_occupied(waypoints[current_waypoint]):
			found_waypoint = true

		if current_waypoint == start_index:
			print("Toate waypoint-urile sunt ocupate!")
			waiting = true
			return

	WaypointManager.occupy_waypoint(waypoints[current_waypoint], self)
	navigation_agent_2d.set_target_position(waypoints[current_waypoint])
	timer.stop()
