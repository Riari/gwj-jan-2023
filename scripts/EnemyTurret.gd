extends Spatial

onready var turret = get_node("Turret")
onready var muzzle = get_node("Turret/Muzzle")
onready var audio_effects = get_node("Audio").get_children()
onready var projectile = preload("res://scenes/objects/enemy-projectile-rocket.tscn")

var rng = RandomNumberGenerator.new()

var rotation_speed = 0.1
var target: Node

var fire_rate = 1 # projectiles fired per second
var fire_timer = 0

func on_aggro_area_entered(node: Node):
	if not node.get_parent().is_in_group("train"):
		return

	target = node.get_parent()

func on_aggro_area_exited(node: Node):
	if not node.get_parent().is_in_group("train"):
		return

	target = null

func _process(delta):
	if not target:
		return

	var transform = turret.global_transform.looking_at(target.global_transform.origin, Vector3.UP)
	var rotation = Quat(turret.global_transform.basis).slerp(Quat(transform.basis), rotation_speed)
	turret.global_transform = Transform(Basis(rotation), turret.global_transform.origin)

	fire_timer += delta

	if fire_timer >= fire_rate:
		fire()
		fire_timer = 0

func fire():
	var p = projectile.instance()
	get_parent().add_child(p)
	p.global_transform = muzzle.global_transform
	p.look_at(target.global_transform.origin, Vector3.UP)
	p.launch()

	rng.randomize()
	var audio_index = rng.randi_range(0, audio_effects.size() - 1)
	audio_effects[audio_index].play()
