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
@onready var inv = get_node("/root/world/Inventar/Inv")
var interact = false
@export var target: Node2D = null
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
var waypoints = []
var current_waypoint = 0
@onready var timer: Timer = $Timer
var waiting = false
var at_destination = false
var interact_stud = false
var id_item_get = ""
var id_item_provide = ""
@onready var list_quest = get_node("/root/world/Inventar/List_quest")
@onready var hour = get_node("/root/world/Cycle_d_n/CanvasLayer/VBoxContainer/HBoxContainer/%Hour")
@onready var ora = get_node("/root/world/Cycle_d_n")
@export var ai_personality: String = ""


@onready var aiText: RichTextLabel = $CanvasLayer/PanelContainer/VBoxContainer/VBoxContainer2/HBoxContainer/RichTextLabel
@onready var textEdit: TextEdit = $CanvasLayer/PanelContainer/VBoxContainer/VBoxContainer2/TextEdit

var available_names := [
	"Ana", "Bogdan", "Cristina", "Darius", "Elena",
	"Florin", "Gabriela", "Horia", "Ioana", "Ionut",
	"Larisa", "Mihai", "Nicoleta", "Ovidiu", "Patricia",
	"Radu", "Simona", "Teodor", "Valentina", "Zoran"
]
var rng := RandomNumberGenerator.new()
var nume= ""

# Flags pentru cămin
var merge_la_camin = false
var in_camin = false

func _ready():
	
	randomize()
	var rnd = randi() % 10 + 1
	var rndi = randi() % 10 + 1
	id_item_get = str(rnd)
	id_item_provide = str(rndi)

	rng.randomize()
	if available_names.size() > 0:
		var idx = rng.randi_range(0, available_names.size() - 1)
		nume = available_names[idx]
		$CanvasLayer/PanelContainer/VBoxContainer/VBoxContainer2/Label.text = "[center]" + nume
		available_names.remove_at(idx)
	print("Nume unic: ", nume)
	ai_personality= "You are "+ nume +", a student of computer science"
	var slot3 = $Quest/PanelContainer/VBoxContainer/HBoxContainer2/SlotContainer3
	slot3.set_property({
		"TEXTURE": load("res://assets/" + ItemData.get_texture(id_item_get)),
		"CANTITATE": 1,
		"NUMBER": int(id_item_get),
		"NUME": ItemData.get_nume(id_item_get)
	})

	await get_tree().process_frame
	healthbar_enemy.value = 0
	add_to_group("enemy_hitbox")
	call_deferred("seeker_setup")

	get_quest()

	# Colectează waypoint-urile de zi (grupa "loc")
	for area in get_tree().get_nodes_in_group("loc"):
		waypoints.append(area.global_position)

	# La start, setăm target la primul loc
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
					break
		if found_waypoint:
			WaypointManager.occupy_waypoint(waypoints[current_waypoint], self)
			navigation_agent_2d.set_target_position(waypoints[current_waypoint])

func _physics_process(_delta):
	# La 08 PM, toți pleacă spre camin
	if hour.text == "08 PM" and not merge_la_camin and not in_camin:
		# ---- ELIBEREAZĂ waypoint ocupat! -----
		if WaypointManager.is_waypoint_occupied(waypoints[current_waypoint]):
			WaypointManager.release_waypoint(waypoints[current_waypoint])
		# --------------------------------------
		merge_la_camin = true
		var camin_list = []
		for area in get_tree().get_nodes_in_group("camin"):
			camin_list.append(area.global_position)
		if camin_list.size() > 0:
			var idx_c = randi() % camin_list.size()
			navigation_agent_2d.set_target_position(camin_list[idx_c])
		else:
			velocity = Vector2.ZERO
			animated_sprite_2d.play("idle")
		return

	# În timpul mersului la camin, nu mai faci alt pathfinding
	if merge_la_camin:
		if navigation_agent_2d.is_navigation_finished():
			in_camin = true
			merge_la_camin = false
		else:
			var next_pos = navigation_agent_2d.get_next_path_position()
			var dir = (next_pos - global_position).normalized()
			velocity = dir * Speed
			move_and_slide()
			movement()
		return

	# La 08 AM, toți reiau plimbarea între locuri
	if hour.text == "08 AM" and in_camin:
		in_camin = false
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
						break
			if found_waypoint:
				WaypointManager.occupy_waypoint(waypoints[current_waypoint], self)
				navigation_agent_2d.set_target_position(waypoints[current_waypoint])

	# ---- RESTUL LOGICII TALE ----

	if interact_stud:
		velocity = Vector2.ZERO
		animated_sprite_2d.play("idle")
		return

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


# Restul funcțiilor rămân la fel (seeker_setup, select_new_direction, movement, quest etc.)


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
			if velocity.x < 0:
				animated_sprite_2d.play("walk-stanga")
				lastPosition = Vector2(-1, 0)
			else:
				animated_sprite_2d.play("walk-dreapta")
				lastPosition = Vector2(1, 0)
		else:
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

func get_player():
	return get_tree().get_first_node_in_group("player")

func _input(event):
	if Input.is_action_just_pressed("interact") and interact:
		if not interact_stud:
			interact_stud = true
			$CanvasLayer.visible = true
			velocity = Vector2.ZERO
			animated_sprite_2d.play("idle")
			get_player().can_move = false  
		else:
			interact_stud = false
			$CanvasLayer.visible = false
			get_player().can_move = true  
			
	if event.is_action("ui_text_newline") and $CanvasLayer.visible:
		send_text_to_ai()


func _on_atack_zone_body_entered(body: Node2D) -> void:
	if body == player:
		GameState.current_ai_npc = self
		interact = true

func _on_atack_zone_body_exited(body: Node2D) -> void:
	if body == player:
		if GameState.current_ai_npc == self:
			GameState.current_ai_npc = null
		interact_stud = false
		$CanvasLayer.visible = false
		$Quest.visible = false
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

func get_quest():
	$Quest/PanelContainer/VBoxContainer/RichTextLabel.text = "I want " + ItemData.get_nume(id_item_provide) + " and you get " + ItemData.get_nume(id_item_get) 

func _on_button_pressed() -> void:
	$Quest.visible = !$Quest.visible

func _on_accept_pressed() -> void:
	$Quest/PanelContainer/VBoxContainer/RichTextLabel.text = "[center]I will wait for it"
	$Quest/PanelContainer/VBoxContainer/HBoxContainer/Accept.visible = false
	$Quest/PanelContainer/VBoxContainer/HBoxContainer/Offer.visible = true

func _on_decline_pressed() -> void:
	$Quest/PanelContainer.visible = false

func _on_offer_pressed() -> void:
	if $Quest/PanelContainer/VBoxContainer/HBoxContainer2/SlotContainer2.item_id == id_item_provide:
		inv.add_item($Quest/PanelContainer/VBoxContainer/HBoxContainer2/SlotContainer3.item_id, 1)
		$Quest/PanelContainer/VBoxContainer/HBoxContainer2/SlotContainer2.clear_item()
		$Quest/PanelContainer/VBoxContainer/HBoxContainer2/SlotContainer3.clear_item()
		$Quest/PanelContainer/VBoxContainer/RichTextLabel.text = ""
		$Quest/PanelContainer/VBoxContainer/HBoxContainer/Offer.visible = false
		$Quest/PanelContainer/VBoxContainer/HBoxContainer/Accept.visible = true
func send_text_to_ai():
	if textEdit.text.strip_edges() == "":
		return

	textEdit.editable = false
	var full_prompt = ai_personality + "\nPlayer: " + textEdit.text
	GameState.global_ai_chat.say(full_prompt)
