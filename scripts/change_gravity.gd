extends Node


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.call("change_gravity")
