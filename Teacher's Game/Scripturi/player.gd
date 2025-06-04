extends CharacterBody2D
var can_move = true
@onready var cycle = get_node("/root/world/Cycle_d_n")
#@onready var quiz = get_node("/root/world/QuizManager")
@onready var rich_text_label: RichTextLabel = $CanvasLayer/RichTextLabel
var sala_curenta: String = ""
var intervale_cu_sali: Array = []

#---------------------------enemy-player-health-control---------------------------------------------------
var player_alive = true
#-----------------------------jump/movement----------------------------------------------------------
var can_jump = true 
var is_jumping = false
var jumpDirection = Vector2.ZERO
var last_direction = Vector2(0, 1)
@onready var camera_2d: Camera2D = $Camera2D
#--------------------------------Animation-start---------------------------------------------------
var _currentIdleAnimation = "down"
@onready var animation_player = $AnimationPlayer
var current_state = "idle"
@onready var animatedSprite2D = $AnimatedSprite2D
@onready var colisiune: CollisionShape2D = $colisiune

#-------------------------------------Info-hand-sprite------------------------------------------
@onready var hand_sprite = $"../Inventar/PanelContainer/Sprite2D/item_mana/sprite"
@onready var info_label = $"../Inventar/InfoLabel"
@onready var area_2d = $"../Inventar/PanelContainer/Sprite2D/item_mana/sprite/Area2D"
@onready var color_rect = $"../Inventar/ColorRect"
var info: String = ""
var study = false
#-------------------------------------Player-stats----------------------------------------------
var Speed = 50
@export var health = 100
var selected_slot: Slot = null 
#----------------------------------TileMap------------------------------------------------------------
@onready var hour = get_node("/root/world/Cycle_d_n/CanvasLayer/VBoxContainer/HBoxContainer/%Hour")
@onready var ora = get_node("/root/world/Cycle_d_n")
@onready var inv: PanelContainer = $"../Inventar/Inv"
@onready var cycle_d_n = get_node("/root/world/Cycle_d_n")
# ------ INTERVALE ORARE PENTRU FIECARE ZI ------

var last_day = 0

#-----------------------------------_ready()--------------------------------------------------------
func _ready():
	update_intervale_afisate()
	add_to_group("player")
	color_rect.color = Color(0, 0, 0, 0.5)
	color_rect.visible = false
	add_to_group("player_hitbox")
	info_label.text = ""
	info_label.visible = false
	last_day = cycle.day_counter

#------------------------------_process()------------------------------------------------------
func _process(_delta):
	update_intervale_afisate()




func update_intervale_afisate():
	if cycle.day_counter == 5:
		rich_text_label.text = "[center][b]Azi este ziua de examen![/b]\nSala: [color=yellow]Aula Magna[/color][/center]"
	else:
		var intervale_cu_sali = cycle.get_intervale_curente()
		var text = "[b]Ore disponibile azi:[/b]\n"
		for interval in intervale_cu_sali:
			if not interval["done"]:
				var ora_start = "%02d:00" % interval["ora"]
				var ora_end = "%02d:00" % (interval["ora"] + interval["durata"])
				var sala = interval["sala"]
				text += "%s - %s  |  Sala: %s\n" % [ora_start, ora_end, sala]
		rich_text_label.text = text



#------------------------------_physics_process()------------------------------------------------------
func _physics_process(delta):
	if not can_move:
		velocity = Vector2.ZERO
		animation_player.play("idle-down")
		return
		
	if health <= 0:
		health = 0
		player_alive = false
		self.queue_free()
		
	if not is_jumping:
		handle_movement()
	
	if Input.is_action_just_pressed("jump") and not is_jumping and can_jump:
		jump()

	if is_jumping:
		position += jumpDirection * Speed  * delta
	else:
		position += velocity * delta

#----------------------------------player-movement------------------------------------------------------
func handle_movement():
	if is_jumping:
		return

	velocity = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		_currentIdleAnimation = "right"
		last_direction = Vector2(1, 0)
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
		_currentIdleAnimation = "left"
		last_direction = Vector2(-1, 0)
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		_currentIdleAnimation = "down"
		last_direction = Vector2(0, 1)
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		_currentIdleAnimation = "up"
		last_direction = Vector2(0, -1)

	if velocity.length() > 0:
		velocity = velocity.normalized() * Speed
		if velocity.x != 0:
			if velocity.x < 0:
				animation_player.play("walk-left")
			else:
				animation_player.play("walk-right")
		elif velocity.y != 0:
			if velocity.y < 0:
				animation_player.play("walk-up")
			else:
				animation_player.play("walk-down")
		current_state = "walking"
	else:
		animation_player.play("idle-" + _currentIdleAnimation)
		current_state = "idle"

	move_and_slide()

#-----------------------------------player-jump--------------------------------------------------------
func jump():
	is_jumping = true
	current_state = "jumping"
	jumpDirection = velocity.normalized()
	if jumpDirection.x > 0:
		animation_player.play("jump-right") 
	elif jumpDirection.x < 0:
		animation_player.play("jump-left") 
	elif jumpDirection.y < 0:
		animation_player.play("jump-up") 
	elif jumpDirection.y > 0:
		animation_player.play("jump-down") 
	elif jumpDirection.y == 0 or jumpDirection.x == 0:
		animation_player.play("jump-down") 
	disable_collision_for_2_seconds()

func _on_timer_timeout():
	colisiune.disabled = false
	is_jumping = false
	
func disable_collision_for_2_seconds():
	colisiune.disabled = true
	get_node("Timer").start()

func _on_body_entered(body):
	if body.is_in_group("player"):
		Speed = 25

func _on_body_exited(body):
	if body.is_in_group("player"):
		Speed = 50

#----------------------------------equip_item/inequip_item---------------------------------------------
func equip_item(item_texture: Texture, item_nume : String):
	if item_texture:
		print("Texture set successfully")
		hand_sprite.texture = item_texture
		hand_sprite.visible = true
		hand_sprite.scale = Vector2(0.5, 0.5)
		info = "[center]ITEM : "  + item_nume + "[/center]"
	else:
		print("Texture is null")

func inequip_item():
	hand_sprite.texture = null
	info_label.visible = false
	info_label.clear()
	info = "" 
	info_label.text = ""

func _on_area_2d_mouse_entered():
	info_label.visible = true
	color_rect.visible = true
	info_label.text = info

func _on_area_2d_mouse_exited():
	info_label.visible = false
	info_label.text = ""
	color_rect.visible = false

func _on_loc_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		study = true

func _on_loc_1_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		study = false
		
func _input(event):
	if event.is_action_pressed("ui_select_1"): 
		if study:
			var probe_list = get_tree().get_nodes_in_group("proba")
			if probe_list.size() > 0:
				var idx = randi() % probe_list.size()
				probe_list[idx].visible = true




func _on_area_2d_body_entered(area: Area2D) -> void:

	if "sala" in area:
		var cod_sala = area.sala
		check_and_update_interval(cod_sala)

func check_and_update_interval(cod_sala: String):
	var hour_str = hour.text.split(" ")[0]
	var period = hour.text.split(" ")[1]
	var ora_actuala = int(hour_str)
	if period == "PM" and ora_actuala != 12:
		ora_actuala += 12
	if period == "AM" and ora_actuala == 12:
		ora_actuala = 0

	for interval in cycle.get_intervale_curente():
		if not interval["done"] and cod_sala == interval["sala"]:
			if ora_actuala >= interval["ora"] and ora_actuala < interval["ora"] + interval["durata"]:
				interval["done"] = true
				update_intervale_afisate()


func _on_loc_10_body_entered(body: Node2D) -> void:
	self.velocity=Vector2.ZERO
	if body.is_in_group("player") and cycle.day_counter==5:
		$"../Cycle_d_n/CanvasLayer".visible=false
		$CanvasLayer.visible=false
		$"../CanvasLayer3".visible=true


func _on_area_2d_11_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		study = true


func _on_area_2d_11_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		study = false


func _on_loc_43_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		study = true


func _on_loc_43_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		study = false


func _on_loc_47_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		study = true

func _on_loc_47_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		study = false


func _on_loc_30_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		study = true


func _on_loc_30_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		study = false


func _on_loc_35_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		study = true


func _on_loc_35_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		study = false
