extends Node


func _ready():
	var vector = "[ "
	for cell in $TileMap.get_used_cells():
		cell -= $TileMap.world_to_map($Unit.position)
		vector += "Vector2 ( " + str(int(cell.x)) + ", " + str(int(cell.y)) + "), "
	print(vector.substr(0, len(vector) - 2) + " ]")
