extends Node2D
class_name RangeIndicator


var range_indicator_tile = preload("res://Unit/Range/range_indicator_tile.tscn")


onready var unit = $"../.."


func update_range(_range, color = Color.black):
	for c in get_children():
		c.queue_free()
	for pos in _range:
		var tile = range_indicator_tile.instance()
		add_child(tile)
		tile.position = position + (pos * unit.stage.get_cell_size()) + \
			Vector2(unit.stage.get_cell_size() / 2, unit.stage.get_cell_size() / 2)
		tile.modulate = color
