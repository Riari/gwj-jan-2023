extends Node

onready var locomotive = get_node("../Locomotive")
onready var track = get_node("../Grid/Track")
onready var start = get_node("../Start")

onready var track_segment_straight = preload("res://scenes/objects/track-straight.tscn")
onready var track_segment_corner = preload("res://scenes/objects/track-corner.tscn")

var last_added_segment_index = -1
var path = Path.new()
var path_follow
var path_end

func _ready():
	var curve = Curve3D.new()
	curve.set_bake_interval(0.3)
	curve.set_up_vector_enabled(false)

	path_end = start.global_translation

	curve = extend_track(curve)

	path.set_curve(curve)

	path_follow = PathFollow.new()
	path_follow.loop = false
	path_follow.rotation_mode = PathFollow.ROTATION_Y

	get_parent().call_deferred("remove_child", locomotive)
	path_follow.call_deferred("add_child", locomotive)

	path.add_child(path_follow)

	add_child(path)

func _process(delta):
	if not path_follow:
		return

	path_follow.offset += delta

func on_hud_entered_track_place_mode():
	var segment = track_segment_corner.instance()
	track.add_child(segment)
	segment.translation = Vector3(2.5, 0, -0.5)

	var curve = extend_track(path.get_curve())
	path.set_curve(curve)

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


func on_car_collision_detected(car: Node, node: Node):
	print(car)
	print(node)
