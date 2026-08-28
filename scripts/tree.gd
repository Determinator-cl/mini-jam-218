extends Area2D

@export_file var fire_scene: String

func _on_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		pass
