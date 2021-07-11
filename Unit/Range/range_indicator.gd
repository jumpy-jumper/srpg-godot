extends Node2D
class_name RangeIndicator


var range_indicator_tile = preload("res://Unit/Range/range_indicator_tile.tscn")


onready var unit = $"../.."


func update_range(_range, color = Color.black):
	var necessary_children = max(0, len(_range) - get_child_count())
	
	for _i in range(necessary_children):
		var tile = range_indicator_tile.instance()
		add_child(tile)
	
	var children = get_children()
	for i in range(len(children)):
		if i >= len(_range):
			children[i].visible = false
		else:
			children[i].visible = true
			children[i].position = position + (_range[i] * unit.stage.get_cell_size()) + \
				Vector2(unit.stage.get_cell_size() / 2, unit.stage.get_cell_size() / 2)
			children[i].modulate = color
