extends Node

onready var locomotive = get_node("../Train/locomotive")
onready var track = get_node("../Track")

var current_track
var current_track_path_follow
var next_track_threshold = 0.1

func _process(delta):
    if current_track_path_follow and current_track_path_follow.unit_offset - next_track_threshold < 1.0:
        current_track_path_follow.unit_offset += delta
        return

    var pieces = track.get_children()

    var closest_piece = pieces[0]

    for piece in pieces:
        if piece.global_translation.distance_to(locomotive.global_translation) < closest_piece.global_translation.distance_to(locomotive.global_translation):
            closest_piece = piece

    if current_track != closest_piece:
        current_track = closest_piece

    current_track_path_follow = current_track.get_node("Path/PathFollow")
    locomotive.get_parent().remove_child(locomotive)
    current_track_path_follow.add_child(locomotive)