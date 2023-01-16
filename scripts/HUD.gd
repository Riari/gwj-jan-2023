extends Control

signal entered_track_place_mode

func on_test_button_pressed():
	emit_signal("entered_track_place_mode")
