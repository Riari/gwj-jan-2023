extends Node

onready var audio_effects = get_node("Audio").get_children()

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	var audio_index = rng.randi_range(0, audio_effects.size() - 1)
	audio_effects[audio_index].play()
