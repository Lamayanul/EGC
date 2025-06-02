extends Area2D


# Called when the node enters the scene tree for the first time.

func _on_body_entered(body: Node2D) -> void:
	if body.name != "player":
		return
		
	var left1 = $"../Barriers/Left1"
	var left2 = $"../Barriers/Left2"
	var right1 = $"../Barriers/Right1"
	var right2 = $"../Barriers/Right2"
	
	var Et0 =   $"../Et0/CollisionShape2D"
	var Et0_2 = $"../Et0/CollisionShape2D2"
	var Et2 = $"../Et2/CollisionShape2D"
	var Et2_2 = $"../Et2/CollisionShape2D2"
	
	Et0.set_deferred("disabled", true)
	Et0_2.set_deferred("disabled", true)
	
	Et2.set_deferred("disabled", false)
	Et2_2.set_deferred("disabled", false)
	
	left1.set_deferred("disabled", false)
	left2.set_deferred("disabled", false)
	
	right1.set_deferred("disabled", true)
	right2.set_deferred("disabled", true)
