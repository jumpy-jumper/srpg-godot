extends Node2D


export(PackedScene) var range_indicator_tile = null


func update_range(_range, cell_size):
	for c in get_children():
		c.queue_free()
	for pos in _range:
		var tile = range_indicator_tile.instance()
		add_child(tile)
		tile.position = position + (pos * cell_size) + Vector2(cell_size / 2, cell_size / 2)