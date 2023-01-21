extends Spatial

onready var turret = get_node("Turret")
onready var muzzle_points = get_node("Turret/MuzzlePoints").get_children()
onready var audio_effects = get_node("Audio").get_children()

export(PackedScene) var projectile
export(String, "player", "enemy") var target_group

# Targeting mode: prioritise newest or oldest target to enter aggro radius
enum TargetingMode { OLDEST, NEWEST }
export(TargetingMode) var targeting_mode

# Group to assign to new projectile instances
export(String, "projectile_player", "projectile_enemy") var projectile_group

export(float) var projectile_scale_modifier = 1.0
export(float) var volley_interval = 1.0 # seconds between volleys
export(float) var projectile_interval = 0.1 # seconds between individual projectiles launching

var rng = RandomNumberGenerator.new()

var rotation_speed = 0.1
var targets = []
var lead_target_index = -1

var volley_timer = 0
var projectile_timer = 0
var muzzle_point_index = -1 # muzzle point to fire from next

func _ready():
	targets.resize(16) # needs to be large enough to contain the maximum possible number of targets

func _process(delta):
	if lead_target_index == -1:
		return

	var transform = turret.global_transform.looking_at(targets[lead_target_index].global_transform.origin, Vector3.UP)
	var rotation = Quat(turret.global_transform.basis).slerp(Quat(transform.basis), rotation_speed)
	turret.global_transform = Transform(Basis(rotation), turret.global_transform.origin)

	volley_timer += delta

	if volley_timer >= volley_interval:
		volley_timer = 0
		muzzle_point_index += 1

	if muzzle_point_index >= 0:
		projectile_timer += delta

		if projectile_timer >= projectile_interval:
			fire(muzzle_point_index)
			muzzle_point_index += 1
			projectile_timer = 0.0

	if muzzle_point_index == muzzle_points.size():
		muzzle_point_index = -1

func on_aggro_area_entered(node: Node):
	if not node.get_parent().is_in_group(target_group):
		return

	# Use the index of the car's PathFollow node
	var node_index = node.get_parent().get_parent().get_index()
	targets[node_index] = node.get_parent()

	if lead_target_index == -1 or targeting_mode == TargetingMode.NEWEST:
		lead_target_index = node_index

func on_aggro_area_exited(node: Node):
	if not node.get_parent().is_in_group(target_group):
		return

	# Use the index of the car's PathFollow node
	var node_index = node.get_parent().get_parent().get_index()

	if targeting_mode == TargetingMode.NEWEST:
		if lead_target_index == node_index:
			targets[node_index] = null
			lead_target_index = -1
			print("disengaging")
	elif targeting_mode == TargetingMode.OLDEST:
		targets[node_index] = null
		lead_target_index += 1

		if targets[lead_target_index] == null:
			lead_target_index = -1

func fire(muzzle_point: int):
	var p = projectile.instance()
	p.add_to_group(projectile_group)
	get_parent().add_child(p)
	p.scale_model(projectile_scale_modifier)
	p.global_transform = muzzle_points[muzzle_point].global_transform
	p.global_rotation = muzzle_points[muzzle_point].global_rotation
	p.launch()

	rng.randomize()
	var audio_index = rng.randi_range(0, audio_effects.size() - 1)
	audio_effects[audio_index].play()
