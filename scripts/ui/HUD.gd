extends Control

signal entered_track_place_mode

onready var train_integrity_bar: TextureProgress = get_node("TopCentre/TrainIntegrity/Bar")

func _ready():
	train_integrity_bar.value = 100

func on_test_button_pressed():
	emit_signal("entered_track_place_mode")

func on_train_integrity_changed(_old: float, new: float):
	train_integrity_bar.value = new
