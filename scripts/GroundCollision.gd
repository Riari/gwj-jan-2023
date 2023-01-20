extends Area

func on_body_entered(body: Node):
	if not body.is_in_group("projectile"):
		return

	body.get_owner().explode()