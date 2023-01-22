extends Node

signal game_won()
signal game_lost()

func trigger_win():
	emit_signal("game_won")

func trigger_loss():
	emit_signal("game_lost")