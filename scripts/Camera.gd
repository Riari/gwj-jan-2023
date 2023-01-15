extends Camera

onready var locomotive = get_node("../Train/locomotive")

func _process(delta):
	transform.origin.z = locomotive.global_translation.z