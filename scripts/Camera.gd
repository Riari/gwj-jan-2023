extends Camera

var follow_target

func follow(node):
	follow_target = node

func _process(_delta):
	if not follow_target:
		return

	transform.origin.z = follow_target.global_translation.z