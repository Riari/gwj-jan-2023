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

var curve_last_extended_to_segment = -1
var path = Path.new()
var path_follows = []
var cars = []
var car_count = 0
var last_car_path_offset = 0.0
var distance_between_cars = 0.5 # in terms of the PathFollow offset value
var path_end
var moving = true

var integrity = 100

signal integrity_changed(old, new)

func _ready():
	var curve = Curve3D.new()
	path_end = start.global_translation
	curve = update_curve(curve)
	path.set_curve(curve)
	add_child(path)

	spawn_car(CAR_TYPE.LOCOMOTIVE)

func _input(_event):
	pass
	# if event is InputEventKey && event.is_action_released("ui_select"):
	# 	var segment = track_segment_straight.instance()
	# 	segment.global_translation = Vector3(2.5, 0, -1.5)
	# 	segment.rotation_degrees = Vector3(0, -90, 0)
	# 	track.add_child(segment)
	# 	path.set_curve(update_curve(path.get_curve()))
	# 	spawn_car(CAR_TYPE.TURRET_SMALL)

func _process(delta):
	if car_count == 0:
		return

	if path_follows[0].unit_offset == 1.0:
		# Locomotive has reached the end of the track
		# TODO: losing condition - show retry/exit menu and maybe derail the train for fun?
		moving = false

	if not moving:
		return

	for i in path_follows.size():
		path_follows[i].offset += delta
		if i == path_follows.size() - 1:
			# Record the last car's PathFollow offset
			last_car_path_offset = path_follows[i].offset

func on_hud_entered_track_place_mode():
	var segment = track_segment_corner.instance()
	track.add_child(segment)
	segment.translation = Vector3(2.5, 0, -0.5)

	var curve = update_curve(path.get_curve())
	path.set_curve(curve)

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
		if points[points.size() - 1].global_translation.distance_to(path_end) < points[0].global_translation.distance_to(path_end):
			for j in range(points.size(), 0, -1):
				path_end = points[j - 1].global_translation
				new_curve.add_point(path_end)
		else:
			for j in points.size():
				path_end = points[j].global_translation
				new_curve.add_point(path_end)

	return new_curve

func on_car_collision_detected(_car: Node, node: Node):
	# TODO: don't hard-code damage
	if node.is_in_group("enemy_projectile"):
		var old_integrity = integrity
		integrity -= 15
		emit_signal("integrity_changed", old_integrity, integrity)
		node.get_owner().explode()


func on_hud_requested_track(_type: String):
	# TODO: Replace with match statement to cover all types
	var segment = track_segment_straight.instance()
	var position = track.get_child(track.get_child_count() - 1).translation
	var rotation = track.get_child(track.get_child_count() - 1).rotation_degrees

	# TODO: Make this dynamic based on track direction
	segment.translation = position
	segment.rotation_degrees = rotation
	segment.translation.z = position.z - 1.0
	track.add_child(segment)
	path.set_curve(update_curve(path.get_curve()))
