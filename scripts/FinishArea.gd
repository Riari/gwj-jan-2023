extends Spatial

signal request_win(car_count)

func on_body_entered(node: Node):
	if not node.get_owner().is_in_group("player"):
		return

	emit_signal("request_win", get_node("../TrainController").get_car_count())
