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


func get_path_to_target():
	var astar = stage.get_astar_graph(traversable)

	target = stage.summoners_cache[0]
	var path = astar.get_point_path(astar.get_closest_point(stage.terrain.world_to_map(position)), 
		astar.get_closest_point(stage.terrain.world_to_map(target.position)))

	var ret = []
	for v in path:
		ret.append(v * stage.get_cell_size())
	return ret


func move():
	var path = get_path_to_target()

	var movement = get_movement()
	movement = movement[(stage.cur_tick - 1) % len(movement)]
	
	if len(path) > movement:
		position = path[movement]
