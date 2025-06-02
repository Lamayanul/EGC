extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body.name != "player":
		return
	
	var corp_c = get_parent()
	var world = corp_c.get_parent()
	var index = world.get_children().find(corp_c)
	world.remove_child(corp_c)
	corp_c.queue_free()
	
	var new_scene = load("res://Scene/Corpuri/corp_c.tscn").instantiate()
	new_scene.position = corp_c.position
	
	world.add_child(new_scene)
	world.move_child(new_scene, index)
