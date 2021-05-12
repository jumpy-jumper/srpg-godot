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
	if selected and stage.get_unit_at(stage.get_world_position(tile)) == null:
		position = stage.get_world_position(tile)
		emit_signal("acted", self, "moved to " + str(stage.get_tilemap_position(position)))
		selected = false
		emit_signal("deselected", self)
