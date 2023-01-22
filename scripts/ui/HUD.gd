extends Control

signal requested_track(type)
signal requested_car(type)

onready var train_integrity_bar: TextureProgress = get_node("TopCentre/TrainIntegrity/Bar")
onready var track_segment_buttons = get_node("BottomCentre/BuildMenu/TrackSegments").get_children()
onready var train_car_buttons = get_node("BottomCentre/BuildMenu/TrainCars").get_children()
onready var pause_menu = get_node("Centre/PauseMenu")
onready var game_lost_menu = get_node("Centre/GameOver")
onready var game_won_menu = get_node("Centre/GameWon")
onready var countdown = get_node("Centre/Countdown")
onready var countdown_label = get_node("Centre/Countdown/TimeLabel")
onready var grid = get_node("../Grid")
onready var money = get_node("BottomCentre/Money")
onready var warning_approacing_track_end_panel = get_node("BottomCentre/WarningApproachingTrackEnd")

var countdown_timer = 3.0

var valid_tracks = {
	GlobalEnums.CardinalDirection.N: [0, 2, 3],
	GlobalEnums.CardinalDirection.E: [1, 5],
	GlobalEnums.CardinalDirection.W: [1, 4]
}

var end_track_direction: int = 0

var track_placed_cooldown = false
var track_placed_cooldown_interval = 0.65
var track_placed_cooldown_timer = 0.0
var track_buttons_enabled = []

var money_amount = 0

func _ready():
	get_tree().paused = true
	countdown.visible = true

	train_integrity_bar.value = 100

	for button in track_segment_buttons:
		button.connect("pressed", self, "on_track_segment_button_pressed", [button.name])

	for button in train_car_buttons:
		button.connect("pressed", self, "on_train_car_button_pressed", [button.name])

func _process(delta):
	if track_placed_cooldown:
		track_placed_cooldown_timer += delta

		if track_placed_cooldown_timer >= track_placed_cooldown_interval:
			for i in track_buttons_enabled:
				track_segment_buttons[i].disabled = false

			track_placed_cooldown_timer = 0.0
			track_placed_cooldown = false

	if not countdown.visible or countdown_timer <= 0.0:
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

	match name:
		"TurretSmall":
			money_amount -= 1500
			money.text = str("$", money_amount)

	if money_amount < 1500:
		train_car_buttons[0].disabled = true

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

func on_game_won(car_count: int):
	game_won_menu.get_node("Panel/CarCount").text = str("You finished with ", car_count, " cars. Nice!")
	get_tree().paused = true
	game_won_menu.visible = true

func on_game_lost():
	get_tree().paused = true
	game_lost_menu.visible = true

func on_track_direction_changed(direction: int):
	end_track_direction = direction
	var valid_track_indices = valid_tracks[direction]

	for button in track_segment_buttons:
		button.disabled = not valid_track_indices.has(button.get_index())

func on_next_track_position_changed(position: Vector3):
	stop_track_end_warning()

	# position is expected to be in world space
	var is_north_valid = grid.is_position_valid(Vector3(position.x, 0, position.z - 1.0))
	var is_east_valid = grid.is_position_valid(Vector3(position.x + 1.0, 0, position.z))
	var is_west_valid = grid.is_position_valid(Vector3(position.x - 1.0, 0, position.z))

	# TODO: improve this
	match end_track_direction:
		GlobalEnums.CardinalDirection.N:
			if not is_north_valid: track_segment_buttons[0].disabled = true
			if not is_east_valid: track_segment_buttons[3].disabled = true
			if not is_west_valid: track_segment_buttons[2].disabled = true
		GlobalEnums.CardinalDirection.E:
			if not is_north_valid: track_segment_buttons[5].disabled = true
			if not is_east_valid: track_segment_buttons[1].disabled = true
		GlobalEnums.CardinalDirection.W:
			if not is_north_valid: track_segment_buttons[4].disabled = true
			if not is_west_valid: track_segment_buttons[1].disabled = true

	cooldown()

func on_enemy_structure_destroyed():
	# TODO: don't hard-code money
	money_amount += 500
	money.text = str("$", money_amount)

	if money_amount >= 1500:
		train_car_buttons[0].disabled = false

func on_approaching_track_end():
	start_track_end_warning()

func cooldown():
	track_buttons_enabled.clear()
	for i in track_segment_buttons.size():
		var button = track_segment_buttons[i]
		if not button.disabled:
			track_buttons_enabled.append(i)

		button.disabled = true

	track_placed_cooldown = true

func start_track_end_warning():
	warning_approacing_track_end_panel.visible = true
	get_node("/root/AudioController").play_warning_alarm()

func stop_track_end_warning():
	warning_approacing_track_end_panel.visible = false
	get_node("/root/AudioController").stop_warning_alarm()
