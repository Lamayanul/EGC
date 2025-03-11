extends TileMap
class_name tilemap

@onready var player = get_node("/root/world/player")
var etaj = 0  

func _ready():
	pass

func _process(delta):
	if player and is_instance_valid(player):
		pass


		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and etaj == 0:
		etaj = 1  
		player.set_collision_layer(2)
		player.set_collision_mask(2)
		switch_floor()

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and etaj == 1:
		etaj = 0  
		player.set_collision_layer(1)
		player.set_collision_mask(1)
		switch_floor()


func switch_floor():
	if etaj == 0:
		$ground_floor2.visible = true
		$items.visible = true
		$"../TileMap2/first_floor".visible = false
		$"../TileMap2/items_2".visible=false
		player.z_index=0
		
	else:
		$ground_floor2.visible = false
		$items.visible = false
		$"../TileMap2/first_floor".visible = true
		$"../TileMap2/items_2".visible=true
		player.z_index=2
		
		


func _on_area_principal_door(body: Node2D) -> void:
	pass
