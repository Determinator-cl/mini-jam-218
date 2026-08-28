extends StaticBody2D

@onready var timer = $Timer
@onready var collision = $CollisionShape2D
@onready var color_rect = $ColorRect

var is_crumbling = false

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player") and not is_crumbling:
		is_crumbling = true
		start_crumble()

func start_crumble():
	timer.start(0.5)

func _on_timer_timeout():
	collision.set_deferred("disabled", true)
	color_rect.visible = false
	
	await get_tree().create_timer(3.0).timeout
	respawn()

func respawn():
	collision.disabled = false
	is_crumbling = false
	color_rect.visible = true
