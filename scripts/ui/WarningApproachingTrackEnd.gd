extends Control

var timer = 0.0
var interval = 0.5

func _process(delta):
	if not visible:
		return

	timer += delta

	if timer >= interval:
		$Panel.visible = !$Panel.visible
		timer = 0.0