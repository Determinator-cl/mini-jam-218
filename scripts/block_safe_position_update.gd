extends Area2D


func _on_body_exited(body: Node2D) -> void:
	body.call("change_can_safe_position", true)

func _on_body_entered(body: Node2D) -> void:
	body.call("change_can_safe_position", false)
