extends Spatial

onready var grid_terrain = get_node("GridMaps/Terrain")
onready var grid_scenery_small = get_node("GridMaps/ScenerySmall")
onready var grid_scenery_large = get_node("GridMaps/SceneryLarge")

var occupied_positions = {}

func _ready():
	for child in $Track.get_children():
		add_node(child)

	for child in $Enemy.get_children():
		add_node(child)

func add_node(node: Node):
	var pos = node.global_translation
	occupied_positions[Vector2(pos.x, pos.z)] = true

func is_position_valid(position: Vector3):
	# position is expected to be in world space
	var is_occupied = occupied_positions.has(Vector2(position.x, position.z))
	var cell_coords = $GridMaps/Terrain.world_to_map($GridMaps.to_local(position))
	var terrain_item = $GridMaps/Terrain.get_cell_item(cell_coords.x, cell_coords.y, cell_coords.z)
	var scenery_large_item = $GridMaps/SceneryLarge.get_cell_item(cell_coords.x, cell_coords.y, cell_coords.z)
	var scenery_small_item = $GridMaps/ScenerySmall.get_cell_item(cell_coords.x, cell_coords.y, cell_coords.z)

	return (not is_occupied
		and terrain_item != GridMap.INVALID_CELL_ITEM
		and scenery_large_item == GridMap.INVALID_CELL_ITEM
		and scenery_small_item == GridMap.INVALID_CELL_ITEM)