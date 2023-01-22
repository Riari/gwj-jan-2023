extends Spatial

var occupied_positions = {}

func _ready():
	for child in $Track.get_children():
		add_position(child.global_translation)

	for child in $Enemy.get_children():
		add_position(child.global_translation)

func add_position(pos: Vector3):
	occupied_positions[Vector2(pos.x, pos.z)] = true

func on_node_added(node: Node):
	print(node)
