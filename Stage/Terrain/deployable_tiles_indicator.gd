extends Node2D


onready var stage = $".."
var indicator = preload("res://Stage/Terrain/deployable_indicator.tscn")


func update_tiles(deployable):
	var _cells = stage.terrain.get_used_cells()
	var cells = []
	for i in range (len(_cells)):
		if not stage.get_unit_at(stage.terrain.map_to_world(_cells[i])) \
			and stage.terrain_types[stage.terrain.get_cellv(_cells[i])] in deployable:
				cells.append(_cells[i])
	
	var necessary_children = max(0, len(cells) - get_child_count())
	
	for i in range(necessary_children):
		var tile = indicator.instance()
		add_child(tile)
	
	var children = get_children()
	for i in range(len(children)):
		if i >= len(cells):
			children[i].visible = false
		else:
			children[i].visible = true
			children[i].position = cells[i] * stage.get_cell_size()
