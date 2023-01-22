extends Spatial

onready var grid_terrain = get_node("GridMaps/Terrain")
onready var grid_scenery_small = get_node("GridMaps/ScenerySmall")
onready var grid_scenery_large = get_node("GridMaps/SceneryLarge")

var occupied_positions = {}
var placeable_terrain_positions = {}

func _ready():
	for child in $Track.get_children():
		add_node(child)

	for child in $Enemy.get_children():
		add_node(child)

	# TODO: Find a better solution to dealing with the offset grid coordinates
	for pos in grid_scenery_small.get_used_cells():
		add_position(Vector3(pos.x + 1, 0, pos.z + 1))

	for pos in grid_scenery_large.get_used_cells():
		var vec3 = Vector3(pos.x + 1, 0, pos.z + 1)
		add_position(vec3)

	# Count centre terrain pieces only
	for pos in grid_terrain.get_used_cells_by_item(0):
		placeable_terrain_positions[Vector2(pos.x, pos.z)] = true

func add_node(node: Node):
	add_position(node.global_translation)

func add_position(pos: Vector3):
	occupied_positions[Vector2(pos.x, pos.z)] = true

func remove_position(pos: Vector3):
	occupied_positions[Vector2(pos.x, pos.z)] = false

func is_position_valid(position: Vector3):
	# position is expected to be in world space
	var vec2 = Vector2(position.x, position.z)
	return not occupied_positions.has(vec2) and placeable_terrain_positions.has(vec2)