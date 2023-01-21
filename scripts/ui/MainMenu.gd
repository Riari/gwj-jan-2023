extends Control

func on_exit_button_pressed():
	get_tree().quit()

func on_credits_button_pressed():
	get_tree().change_scene("res://scenes/Credits.tscn")

func on_play_button_pressed():
	get_tree().change_scene("res://scenes/InGame.tscn")
