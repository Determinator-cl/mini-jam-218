extends Label

@onready var player = $"../../Player"

func _ready():
	player.hp_changed.connect(_on_hp_changed)
	text = "Health: " + str(player.hp) 

func _on_hp_changed(new_hp):
	text = "Health: " + str(new_hp)
