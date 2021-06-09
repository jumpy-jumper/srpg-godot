class_name Enemy
extends Unit


func get_type_of_self():
	return UnitType.ENEMY


func get_enemy_unit_type():
	return UnitType.FOLLOWER


func _on_Cursor_confirm_issued(pos):
	._on_Cursor_confirm_issued(pos)
	var unit = stage.get_unit_at(pos)
	
	if stage.selected_unit == self:
		if unit != null:
			if unit is PlayerUnit:
				var dmg = (base_atk - unit.base_def) if unit is Follower else 1
				unit.take_damage(dmg, DamageType.PHYSICAL)
				emit_signal("acted", self, "attacked " + unit.unit_name \
					+ " for " + str(dmg))
				stage.selected_unit = null
		else:
			position = pos
			emit_signal("acted", self, "moved to " + str(pos))
			stage.deselect_unit()
	elif stage.selected_unit == null and pos == position:
		stage.select_unit(self)


func _on_Cursor_cancel_issued(pos):
	._on_Cursor_cancel_issued(pos)
	if stage.selected_unit == self:
		stage.deselect_unit()


###############################################################################
#        Tick and basic action                                                #
###############################################################################


func tick():
	move()


###############################################################################
#        Movement	                                                          #
###############################################################################


var target = null


export var base_mov = [0, 1, 0, 1]
export(Array, Resource) var traversable = []


func get_movement():
	return base_mov


func get_path():
	target = stage.summoners_cache[0]
	
	var astar = AStar2D.new()
	
	var terrain = stage.level.get_node("Terrain")
	var this_tile = terrain.world_to_map(position)
	astar.add_point(0, this_tile)
	
	var adjacent = [Vector2(0, 1), Vector2(0, -1), Vector2(-1, 0), Vector2(1, 0)]
	var visited_id = [0]
	var visited_pos = [this_tile]
	while len(visited_id) > 0:
		var cur_id = visited_id.pop_back()
		var cur_pos = astar.get_point_position(cur_id)
		for a in adjacent:
			if terrain.get_cellv(cur_pos + a) != -1 \
				and not cur_pos + a in visited_pos \
				and stage.terrain_types[terrain.get_cellv(cur_pos + a)] in traversable:
					var id = astar.get_available_point_id()
					visited_id.append(id)
					visited_pos.append(cur_pos + a)
					astar.add_point(id, cur_pos + a)
					astar.connect_points(cur_id, id)


	var path = astar.get_point_path(0, astar.get_closest_point(terrain.world_to_map(target.position)))
	var ret = []
	for v in path:
		ret.append(v * stage.get_cell_size())
	return ret


func move():
	var path = get_path()

	var movement = get_movement()
	movement = movement[(stage.cur_tick - 1) % len(movement)]
	
	if len(path) > movement:
		position = path[movement]
