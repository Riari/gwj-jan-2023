extends Spatial

var launched = false

func launch():
	launched = true

func _process(delta):
	if not launched:
		return

	translate(transform.basis.z.normalized() * delta)