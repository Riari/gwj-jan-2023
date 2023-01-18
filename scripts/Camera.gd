extends Camera

onready var locomotive = get_node("../Locomotive")

func _process(_delta):
	transform.origin.z = locomotive.global_translation.z