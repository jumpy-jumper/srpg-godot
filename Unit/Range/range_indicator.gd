extends Node2D



export(Color) var inactive_color
export(Color) var active_color


export(PackedScene) var range_indicator_tile = null


func update_range(_range, cell_size, skill_active = false):
	for c in get_children():
		c.queue_free()
	for pos in _range:
		var tile = range_indicator_tile.instance()
		add_child(tile)
		tile.position = position + (pos * cell_size) + Vector2(cell_size / 2, cell_size / 2)
		tile.modulate = active_color if skill_active else inactive_color
