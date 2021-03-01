class_name Follower
extends PlayerUnit


enum Facing {RIGHT, DOWN, LEFT, UP}

export(Facing) var facing = Facing.UP


func get_unit_type():
	return UnitType.FOLLOWER


func get_state():
	var state = .get_state()
	state["facing"] = facing
	return state


func _on_Stage_tile_clicked(tile):
	if operatable:
		if not selected:
			selected = tile == stage.get_tilemap_position(position)
		elif selected:
			position = stage.get_world_position(tile)
			emit_signal("acted")
			selected = false
