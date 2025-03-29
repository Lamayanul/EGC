extends TileMap
class_name tilemap

@onready var player = get_node("/root/world/player")
var etaj = 0  
var can_change_floor = false  # Variabilă care determină dacă putem schimba etajele

func _process(delta):
	if player and is_instance_valid(player):
		check_roof()

	# Verifică doar dacă jucătorul este într-o zonă validă
	if can_change_floor:
		if Input.is_action_just_pressed("et0") and etaj != 0:
			change_floor(0)
		elif Input.is_action_just_pressed("et1") and etaj != 1:
			change_floor(1)
		elif Input.is_action_just_pressed("et2") and etaj != 2:
			change_floor(2)

func check_roof():
	var player_pos = player.global_position
	var player_cell = local_to_map(player_pos)
	var tile_data_player = $roof.get_cell_tile_data(player_cell)
	if tile_data_player and tile_data_player.get_custom_data("roof"): 
		$roof.modulate = Color(0, 0, 0, 0) 
	else:
		$roof.modulate = Color(1, 1, 1, 1)

func change_floor(target_floor: int):
	if etaj == target_floor:
		return
	
	etaj = target_floor
	switch_floor()

func switch_floor():
	if etaj == 0:
		$ground_floor2.visible = true
		$items.visible = true
		$"../TileMap2/first_floor".visible = false
		$"../TileMap2/items_2".visible = false
		$roof.visible = true
		$"../TileMap3/item_3".visible = false
		$"../TileMap3/second_floor".visible = false
		$"../player".collision_mask=1
		player.z_index = 0
		
	elif etaj == 1:
		$ground_floor2.visible = false
		$items.visible = false
		$"../TileMap2/first_floor".visible = true
		$"../TileMap2/items_2".visible = true
		$roof.visible = false
		$"../TileMap3/item_3".visible = false
		$"../TileMap3/second_floor".visible = false
		$"../player".collision_mask=2
		player.z_index = 2
		
	elif etaj == 2:
		$"../TileMap3/item_3".visible = true
		$"../TileMap3/second_floor".visible = true
		$ground_floor2.visible = false
		$items.visible = false
		$"../TileMap2/first_floor".visible = false
		$"../TileMap2/items_2".visible = false
		$roof.visible = false
		$"../player".collision_mask=4
		player.z_index = 4


# 📌 Detectează când jucătorul intră într-o zonă validă pentru schimbare
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_change_floor = true  # Jucătorul poate acum să schimbe etajele

# 📌 Detectează când jucătorul iese din zona validă
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_change_floor = false  # Jucătorul nu mai poate schimba etajele
