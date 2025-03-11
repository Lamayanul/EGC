extends CharacterBody2D

var Speed = 20
var health=100
@onready var animated_sprite_2d = $AnimatedSprite2D
var original_color = Color(1, 1, 1, 1)  
var hit_color = Color(1, 0, 0, 1) 
@onready var color = $color
var moveDirection = Vector2.ZERO
@onready var healthbar = $healthbar
@onready var animation_player = $AnimationPlayer
@onready var player = $"../player"
@export var MoveSpeed: float = 20.0
var lastPosition=Vector2(0,1)
@onready var detection = $detection
@onready var player_hitbox = get_node("/root/world/player/player_hitbox")
@onready var enemy_icon = $"../player/CanvasLayer/healthbar_enemy/enemy_icon"
@onready var healthbar_enemy = $"../player/CanvasLayer/healthbar_enemy"
var interact=false
@export var target: Node2D = null
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D



func _ready():
	healthbar_enemy.value=0
	#$ChangeDirection.start()
	add_to_group("enemy_hitbox")
	call_deferred("seeker_setup")
	


func _physics_process(_delta):
	if is_instance_valid(target):
		navigation_agent_2d.target_position = target.global_position
	
	if navigation_agent_2d.is_navigation_finished():
		return

	
	var current_agent_position = global_position
	var next_path_position = navigation_agent_2d.get_next_path_position()
	var new_velocity = current_agent_position.direction_to(next_path_position) * Speed
	
	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
		
	move_and_slide()
	movement()  

		
	#velocity = moveDirection * MoveSpeed
	#movement()
	#move_and_slide()
	
	


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
	if velocity!=Vector2.ZERO:
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
	animated_sprite_2d.modulate=original_color



func _on_change_direction_timeout():
	select_new_direction()
	
func _input(event):
	if Input.is_action_just_pressed("interact") and interact:
		moveDirection = Vector2.ZERO
		animated_sprite_2d.play("idle") 


func _on_atack_zone_body_entered(body: Node2D) -> void:
	interact=true


func _on_atack_zone_body_exited(body: Node2D) -> void:
	interact=false


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	pass
