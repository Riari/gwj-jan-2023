extends Control

signal requested_track(type)

onready var train_integrity_bar: TextureProgress = get_node("TopCentre/TrainIntegrity/Bar")
onready var track_segment_buttons = get_node("BottomCentre/BuildMenu/TrackSegments").get_children()

func _ready():
	train_integrity_bar.value = 100

	for button in track_segment_buttons:
		button.connect("pressed", self, "on_track_segment_button_pressed", [button.name])

func on_test_button_pressed():
	emit_signal("entered_track_place_mode")

func on_train_integrity_changed(_old: float, new: float):
	train_integrity_bar.value = new

func on_track_segment_button_pressed(name: String):
	emit_signal("requested_track", name)