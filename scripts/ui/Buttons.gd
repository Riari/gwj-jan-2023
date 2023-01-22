extends Control

func _ready():
	for child in get_children():
		child.connect("pressed", get_node("/root/AudioController"), "play_click")