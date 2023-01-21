extends Sprite3D

export(int) var min_value
export(int) var max_value = 100

func _ready():
	texture = $Viewport.get_texture()
	$Viewport/TextureProgress.min_value = min_value
	$Viewport/TextureProgress.max_value = max_value

func set_value(value: int):
	$Viewport/TextureProgress.value = value