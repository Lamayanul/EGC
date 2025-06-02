extends Area2D



func _on_body_entered(body: Node2D) -> void:
	print("Body entered!")
	if body.name == "player":
		print("player entered!")
		
		var corp_c_et1 = get_parent()
		var world = corp_c_et1.get_parent()
		var index = world.get_children().find(corp_c_et1)
		world.remove_child(corp_c_et1)
		corp_c_et1.queue_free()
		
		var new_scene = load("res://Scene/Corpuri/corp_c.tscn").instantiate()
		new_scene.position = corp_c_et1.position
		
		world.add_child(new_scene)
		world.move_child(new_scene, index)
