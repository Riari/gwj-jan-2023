extends Control

func on_how_to_play_button_pressed():
	get_tree().change_scene("res://scenes/HowToPlay.tscn")

func on_play_button_pressed():
	get_tree().change_scene("res://scenes/InGame.tscn")

func on_credits_button_pressed():
	get_tree().change_scene("res://scenes/Credits.tscn")

func on_exit_button_pressed():
	get_tree().quit()
