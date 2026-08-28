extends Area2D


const damage = 1


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.call("take_damage_from_danger", damage)
