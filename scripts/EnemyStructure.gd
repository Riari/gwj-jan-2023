extends Spatial

onready var integrity_bar = get_node("3DProgressBar")
onready var sounds_explosion = get_node("Audio/Explosions").get_children()

var is_destroyed = false
var destroy_fall_speed = 0.5
var destroy_duration = 1.0
var destroy_timer = 0.0
var integrity = 100

var rng = RandomNumberGenerator.new()

signal enemy_structure_destroyed()

func _ready():
	integrity_bar.set_value(integrity)

func _process(delta):
	if not is_destroyed:
		return

	destroy_timer += delta
	global_translation.y -= destroy_fall_speed * delta

	if destroy_timer >= destroy_duration:
		queue_free()

func on_body_entered(node: Node):
	if not node.get_parent().is_in_group("projectile_player"):
		return

	if not integrity_bar.visible:
		integrity_bar.visible = true

	# TODO: Don't hard-code damage
	integrity -= 12
	integrity_bar.set_value(integrity)
	node.get_owner().explode()

	if integrity <= 0:
		destroy()

func destroy():
	if is_destroyed:
		return

	is_destroyed = true
	integrity_bar.visible = false
	emit_signal("enemy_structure_destroyed")
	sounds_explosion[rng.randi_range(0, sounds_explosion.size() - 1)].play()