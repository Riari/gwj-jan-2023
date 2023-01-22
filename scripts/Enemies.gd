extends Node

func _ready():
	for child in get_children():
		child.connect("enemy_structure_destroyed", get_node("../../HUD"), "on_enemy_structure_destroyed")