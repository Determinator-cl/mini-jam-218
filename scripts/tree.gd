extends Area2D

@export var fire_scene: PackedScene
var is_triggered: bool = false
var spawn_positions: Array[Vector2] = [
	Vector2(0, 0),
	Vector2(20, -10),
	Vector2(0, -20)
]

func _on_body_entered(body: Node2D):
	if body.is_in_group("Player") and not is_triggered:
		is_triggered = true
		spawn_fires()
		

func spawn_fires():
	if not fire_scene:
		return

	for pos in spawn_positions:
		var fire_instance = fire_scene.instantiate()
		add_child(fire_instance)
		fire_instance.position = pos
