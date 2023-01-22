extends Control

signal requested_track(type)
signal requested_car(type)

onready var train_integrity_bar: TextureProgress = get_node("TopCentre/TrainIntegrity/Bar")
onready var track_segment_buttons = get_node("BottomCentre/BuildMenu/TrackSegments").get_children()
onready var train_car_buttons = get_node("BottomCentre/BuildMenu/TrainCars").get_children()
onready var pause_menu = get_node("Centre/PauseMenu")
onready var game_lost_menu = get_node("Centre/GameOver")
onready var countdown = get_node("Centre/Countdown")
onready var countdown_label = get_node("Centre/Countdown/TimeLabel")

var countdown_timer = 3.0

func _ready():
	get_tree().paused = true

	train_integrity_bar.value = 100

	for button in track_segment_buttons:
		button.connect("pressed", self, "on_track_segment_button_pressed", [button.name])

	for button in train_car_buttons:
		button.connect("pressed", self, "on_train_car_button_pressed", [button.name])

func _process(delta):
	if not countdown.visible:
		return

	countdown_timer -= delta

	if countdown_timer <= 0.0:
		get_tree().paused = false
		countdown.visible = false
		return

	countdown_label.text = str(int(ceil(countdown_timer)), "...")

func on_train_integrity_changed(_old: float, new: float):
	train_integrity_bar.value = new

func on_track_segment_button_pressed(name: String):
	emit_signal("requested_track", name)

func on_train_car_button_pressed(name: String):
	emit_signal("requested_car", name)

func on_pause_state_changed(is_paused: bool):
	pause_menu.visible = is_paused

func on_pause_menu_continue_pressed():
	get_tree().paused = false
	pause_menu.visible = false

func on_exit_to_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://scenes/MainMenu.tscn")

func on_exit_game_button_pressed():
	get_tree().quit()

func on_game_over_restart_pressed():
	get_tree().reload_current_scene()

func on_game_won():
	pass # Replace with function body.

func on_game_lost():
	get_tree().paused = true
	game_lost_menu.visible = true
