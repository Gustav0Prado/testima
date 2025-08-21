class_name EnemySpawnAreas extends TileMapLayer

const AREAS_WEIGHTED: Array = [
	[
		"Bat", 1,
		"Slime", 3
	],
	[
		"Bat", 2,
		"Slime", 1,
		"Cocky Roach", 3
	],
]

func _ready() -> void:
	hide()
	
func get_enemies_weighted(pos: Vector2) -> Array:
	var cell: Vector2 = local_to_map(pos)
	var autotile_width: int = 4
	var autotile_coord: Vector2i = get_cell_atlas_coords(cell)
	var area_index: int = autotile_coord.x + autotile_coord.y * autotile_width
	return AREAS_WEIGHTED[area_index]
