extends Node

onready var track = get_node("../Grid/Track")
onready var start = get_node("../Start")
onready var camera = get_node("../Camera")
onready var win_loss_controller = get_node("../WinLossController")

onready var track_segment_straight = preload("res://scenes/objects/track-straight.tscn")
onready var track_segment_corner = preload("res://scenes/objects/track-corner.tscn")

enum CAR_TYPE {
	LOCOMOTIVE,
	TURRET_SMALL
}
onready var train_locomotive = preload("res://scenes/objects/train-locomotive.tscn")
onready var train_car_turret_small = preload("res://scenes/objects/train-car-turret-small.tscn")

var curve_last_extended_to_segment = -1
var last_segment_direction = GlobalEnums.CardinalDirection.N
var next_segment_position
var path = Path.new()
var path_follows = []
var cars = []
var car_count = 0
var last_car_path_offset = 0.0
var movement_speed = 0.8
var distance_between_cars = 0.5 # in terms of the PathFollow offset value
var path_end
var moving = true
var spawn_second_car_delay = 0.5
var spawn_second_car_timer = 0.0
var track_end_warning_threshold = 2.0
var track_ending_warning_triggered = false

var integrity = 100

signal integrity_changed(old, new)
signal track_direction_changed(direction)
signal next_track_position_changed(position)
signal approaching_track_end()

func _ready():
	var curve = Curve3D.new()
	path_end = start.global_translation
	curve = update_curve(curve)
	path.set_curve(curve)
	add_child(path)

	spawn_car(CAR_TYPE.LOCOMOTIVE)

func _process(delta):
	if car_count == 0:
		return

	if car_count == 1:
		spawn_second_car_timer += delta
		if spawn_second_car_timer >= spawn_second_car_delay:
			spawn_car(CAR_TYPE.TURRET_SMALL)

	if path.get_curve().get_baked_length() - path_follows[0].offset <= track_end_warning_threshold and not track_ending_warning_triggered:
		emit_signal("approaching_track_end")
		track_ending_warning_triggered = true

	if path_follows[0].unit_offset == 1.0:
		# Locomotive has reached the end of the track
		win_loss_controller.trigger_loss()
		moving = false

	if not moving:
		return

	for i in path_follows.size():
		path_follows[i].offset += movement_speed * delta
		if i == path_follows.size() - 1:
			# Record the last car's PathFollow offset
			last_car_path_offset = path_follows[i].offset

func spawn_car(type: int):
	var car
	match type:
		CAR_TYPE.LOCOMOTIVE:
			# This should only be spawned once and the camera should follow it
			car = train_locomotive.instance()
			camera.follow(car)
		CAR_TYPE.TURRET_SMALL:
			car = train_car_turret_small.instance()

	var path_follow = PathFollow.new()
	path_follow.loop = false
	path_follow.rotation_mode = PathFollow.ROTATION_ORIENTED
	path_follow.add_child(car)

	if car_count > 0:
		path_follow.offset = last_car_path_offset - distance_between_cars

	path_follows.append(path_follow)
	car.connect("collision_detected", self, "on_car_collision_detected")
	car.show()
	cars.append(car)
	car_count += 1

	path.add_child(path_follow)

func get_car_count():
	return car_count + 1 # including locomotive

# update_curve updates the given curve to match the current state of track segments
func update_curve(curve):
	var new_curve = curve
	var segments = track.get_children()

	# Assume track segments are ordered from closest to furthest
	for i in range(curve_last_extended_to_segment + 1, segments.size(), 1):
		# Path points within a segment should also be in distance order
		var points = segments[i].get_node("PathPoints").get_children()
		curve_last_extended_to_segment = i

		# Determine which way to traverse the points - from last to first if the last point is closer, otherwise first to last
		if points[-1].global_translation.distance_to(path_end) < points[0].global_translation.distance_to(path_end):
			for j in range(points.size(), 0, -1):
				path_end = points[j - 1].global_translation
				new_curve.add_point(path_end)
		else:
			for j in points.size():
				path_end = points[j].global_translation
				new_curve.add_point(path_end)

	# TODO: improve this - it's a crude way of determining direction based on the anatomy of PathPoints in the last segment
	var last_segment = segments[-1]
	last_segment_direction = determine_direction(last_segment)
	var previous_position = last_segment.translation

	var position = previous_position
	match last_segment_direction:
		GlobalEnums.CardinalDirection.N:
			position.z -= 1.0
		GlobalEnums.CardinalDirection.E:
			position.x += 1.0
		GlobalEnums.CardinalDirection.W:
			position.x -= 1.0

	next_segment_position = position

	emit_signal("track_direction_changed", last_segment_direction)
	emit_signal("next_track_position_changed", track.to_global(next_segment_position))
	track_ending_warning_triggered = false

	return new_curve

func determine_direction(segment: Spatial):
	var is_straight = segment.is_in_group("track_straight")
	var y_rotation_degrees = int(segment.rotation_degrees.y)

	if is_straight:
		match y_rotation_degrees:
			0:
				return GlobalEnums.CardinalDirection.N
			-90:
				return GlobalEnums.CardinalDirection.E
			90:
				return GlobalEnums.CardinalDirection.W
	else:
		match y_rotation_degrees:
			0:
				return GlobalEnums.CardinalDirection.E
			-90:
				return GlobalEnums.CardinalDirection.W
			90:
				return GlobalEnums.CardinalDirection.N
			-180:
				return GlobalEnums.CardinalDirection.N

func on_car_collision_detected(_car: Node, node: Node):
	# TODO: don't hard-code damage
	if node.get_parent().is_in_group("projectile_enemy"):
		var old_integrity = integrity
		integrity -= 1
		emit_signal("integrity_changed", old_integrity, integrity)
		node.get_owner().explode()

		if integrity <= 0:
			win_loss_controller.trigger_loss()

func on_hud_requested_track(type: String):
	var segment
	var rotation_degrees = 0.0
	if type == "StraightN" or type == "StraightEW":
		segment = track_segment_straight.instance()
		if type == "StraightEW":
			if last_segment_direction == GlobalEnums.CardinalDirection.E:
				rotation_degrees = -90.0
			if last_segment_direction == GlobalEnums.CardinalDirection.W:
				rotation_degrees = 90.0
	else:
		segment = track_segment_corner.instance()
		match type:
			"CornerSW":
				rotation_degrees = -90.0
			"CornerWN":
				rotation_degrees = 90.0
			"CornerEN":
				rotation_degrees = -180.0

	segment.translation = next_segment_position
	segment.rotation_degrees.y = rotation_degrees

	track.add_child(segment)
	path.set_curve(update_curve(path.get_curve()))

func on_hud_requested_car(type: String):
	match type:
		"TurretSmall":
			spawn_car(CAR_TYPE.TURRET_SMALL)
