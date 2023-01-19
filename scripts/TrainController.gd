extends Node

onready var track = get_node("../Grid/Track")
onready var start = get_node("../Start")
onready var camera = get_node("../Camera")

onready var track_segment_straight = preload("res://scenes/objects/track-straight.tscn")
onready var track_segment_corner = preload("res://scenes/objects/track-corner.tscn")

enum CAR_TYPE {
	LOCOMOTIVE,
	TURRET_SMALL
}
onready var train_locomotive = preload("res://scenes/objects/train-locomotive.tscn")
onready var train_car_turret_small = preload("res://scenes/objects/train-car-turret-small.tscn")

var last_added_segment_index = -1
var path = Path.new()
var path_follows = []
var cars = []
var car_count = 0
var last_car_path_offset = 0.0
var distance_between_cars = 0.5 # in terms of the PathFollow offset value
var path_end
var moving = true

# last_car_in_position is used for newly spawned cars: when a car is spawned, it's initially invisible and
# waits on the track until its distance to the one in front is equal to or greater than distance_between_cars.
# This means that if spawned on a corner, its rotation will be correct when it becomes visible and starts moving.
var last_car_in_position = true

func _ready():
	var curve = Curve3D.new()
	curve.set_bake_interval(0.3)
	curve.set_up_vector_enabled(false)

	path_end = start.global_translation
	curve = extend_track(curve)
	path.set_curve(curve)
	add_child(path)

	spawn_car(CAR_TYPE.LOCOMOTIVE)

func _input(event):
	if event is InputEventKey && event.is_action_released("ui_select"):
		spawn_car(CAR_TYPE.TURRET_SMALL)

func _process(delta):
	if car_count == 0:
		return

	if path_follows[0].unit_offset == 1.0:
		# Locomotive has reached the end of the track
		# TODO: losing condition - show retry/exit menu and maybe derail the train for fun?
		moving = false

	if not last_car_in_position:
		if path_follows[car_count - 2].offset - path_follows[car_count - 1].offset >= distance_between_cars:
			cars[car_count - 1].show()
			last_car_in_position = true

	if not moving:
		return

	for i in path_follows.size():
		if not last_car_in_position and i == car_count - 1:
			break

		path_follows[i].offset += delta
		if i == path_follows.size() - 1:
			# Record the last car's PathFollow offset
			last_car_path_offset = path_follows[i].offset

func on_hud_entered_track_place_mode():
	var segment = track_segment_corner.instance()
	track.add_child(segment)
	segment.translation = Vector3(2.5, 0, -0.5)

	var curve = extend_track(path.get_curve())
	path.set_curve(curve)

func spawn_car(type: int):
	var car
	match type:
		CAR_TYPE.LOCOMOTIVE:
			# This should only be spawned once and the camera should follow it
			car = train_locomotive.instance()
			car.show()
			camera.follow(car)
		CAR_TYPE.TURRET_SMALL:
			car = train_car_turret_small.instance()

	var path_follow = PathFollow.new()
	path_follow.loop = false
	path_follow.rotation_mode = PathFollow.ROTATION_Y
	path_follow.add_child(car)

	if car_count > 0:
		path_follow.offset = last_car_path_offset
		car.global_rotation = cars[car_count - 1].global_rotation
		car.visible = false
		last_car_in_position = false

	path_follows.append(path_follow)
	cars.append(car)
	car_count += 1

	path.add_child(path_follow)

func extend_track(curve):
	var new_curve = curve
	var segments = track.get_children()

	# Assume track segments are ordered from closest to furthest
	for i in range(last_added_segment_index + 1, segments.size(), 1):
		var points = segments[i].get_node("PathPoints").get_children()
		last_added_segment_index = i

		if points[points.size() - 1].global_translation.distance_to(path_end) < points[0].global_translation.distance_to(path_end):
			for j in range(points.size() - 1, 0, -1):
				path_end = points[j].global_translation
				new_curve.add_point(path_end)
		else:
			for j in points.size():
				path_end = points[j].global_translation
				new_curve.add_point(path_end)

	return new_curve

func on_car_collision_detected(_car: Node, _node: Node):
	pass
