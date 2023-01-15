extends Camera

onready var locomotive = get_node("../Locomotive")

func _process(delta):
	transform.origin.z = locomotive.global_translation.z