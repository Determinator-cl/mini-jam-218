extends Area2D
class_name Door

@export var door_type: String # Тип двери (куда игрок выйдет из этой двери: up, down, left, right)
@export var target_room: String # Комната в которую попадём
@export var target_door: String # Конкретная дверь в комнате из которой выйдем

signal door_triggered(target_room_path: String, target_door_id: String)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		door_triggered.emit(target_room, target_door)	
