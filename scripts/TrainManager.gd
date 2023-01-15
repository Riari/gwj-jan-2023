extends Node

onready var locomotive = get_node("../Locomotive")
onready var start = get_node("../Start")

var path_follow

func _ready():
	# Assume tracks are ordered from closest to furthest
	var tracks = get_node("../Track").get_children()

	var curve = Curve3D.new()
	curve.set_bake_interval(0.3)
	curve.set_up_vector_enabled(false)

	var position = start.global_translation

	for track in tracks:
		var points = track.get_node("PathPoints").get_children()

		if points[points.size() - 1].global_translation.distance_to(position) < points[0].global_translation.distance_to(position):
			for j in range(points.size() - 1, 0, -1):
				position = points[j].global_translation
				curve.add_point(position)
		else:
			for point in points:
				position = point.global_translation
				curve.add_point(position)

	var path = Path.new()
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

# func _process(delta):
#     if current_track_path_follow and current_track_path_follow.unit_offset < 1.0:
#         current_track_path_follow.unit_offset += delta
#         print(current_track_path_follow.unit_offset)
#         return

#     var pieces = track.get_children()

#     var closest_piece = pieces[0]

#     for piece in pieces:
#         if piece.global_translation.distance_to(locomotive.global_translation) < closest_piece.global_translation.distance_to(locomotive.global_translation):
#             closest_piece = piece

#     if current_track != closest_piece:
#         current_track = closest_piece

#     current_track_path_follow = current_track.get_node("Path/PathFollow")
#     locomotive.get_parent().remove_child(locomotive)
#     current_track_path_follow.add_child(locomotive)
