extends Node2D

@export_file("*.tscn") var start_room: String
@export var player: CharacterBody2D
@export var fade_screen: CanvasLayer

var current_room_instance: Node2D = null

func _ready() -> void:
	if start_room:
		change_room(start_room, "")


func change_room(room_path: String, target_door_id: String) -> void:
	# Временно отключаю физику игрока
	if player:
		player.set_physics_process(false)
		player.velocity = Vector2.ZERO

	# Затемнение
	if fade_screen:
		await fade_screen.fade_in(0.3)

	# Удаляем текущую комнату
	if current_room_instance:
		current_room_instance.queue_free()
		await current_room_instance.tree_exited

	# Спавним новую
	var room_res = load(room_path)
	current_room_instance = room_res.instantiate()
	add_child(current_room_instance)

	# Подключаем двери в новой комнате и ищем целевую
	var target_door_node: Door = null
	for child in current_room_instance.get_children():
		if child is Door:
			child.door_triggered.connect(_on_door_triggered)
			if target_door_id != "" and (child.name == target_door_id or child.door_type == target_door_id):
				target_door_node = child

	# Тепаем игрока
	if target_door_node and player:
		var offset = Vector2.ZERO
		match target_door_node.door_type:
			"up": offset = Vector2(48, -32) if player.last_direct == 1.0 else Vector2(-48, -32)
			"down": offset = Vector2(0, 32)
			"left": offset = Vector2(-32, 0)
			"right": offset = Vector2(32, 0)

		player.global_position = target_door_node.global_position + offset

	# Включаем физику обратно
	if player:
		player.set_physics_process(true)

	# Разтемнение	
	if fade_screen:
		await fade_screen.fade_out(0.3)


func _on_door_triggered(target_room_path: String, target_door_id: String) -> void:
	change_room(target_room_path, target_door_id)
