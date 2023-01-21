extends Node

signal pause_state_changed(is_paused)

func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = !get_tree().paused
		emit_signal("pause_state_changed", get_tree().paused)