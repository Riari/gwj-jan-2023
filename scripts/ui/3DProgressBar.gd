extends Sprite3D

onready var bar = get_node("Viewport/TextureProgress")

export(int) var min_value = 0
export(int) var max_value = 100

func _ready():
	texture = $Viewport.get_texture()
	bar.min_value = min_value
	bar.max_value = max_value

func set_value(value: int):
	bar.value = value