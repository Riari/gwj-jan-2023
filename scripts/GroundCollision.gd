extends Area

onready var vfx_explosion = preload("res://scenes/effects/explosion-1.tscn")

var vfx_time = 2.0
var vfx_active = []
var vfx_timers = []

func on_body_entered(body: Node):
	var node = body.get_owner()
	if not node.is_in_group("projectile"):
		return

	var vfx = vfx_explosion.instance()
	vfx.global_transform = body.global_transform
	add_child(vfx)

	vfx_active.append(vfx)
	vfx_timers.append(vfx_time)

	var projectile = body.get_parent()
	projectile.queue_free()

func _process(delta):
	var to_remove = []

	for i in vfx_timers.size():
		vfx_timers[i] -= delta
		if vfx_timers[i] <= 0.0:
			to_remove.append(i)

	for i in to_remove:
		remove_child(vfx_active[i])
		vfx_active.remove(i)
		vfx_timers.remove(i)