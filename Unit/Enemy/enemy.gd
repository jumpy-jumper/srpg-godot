class_name Enemy
extends Unit


func get_type_of_self():
	return UnitType.ENEMY


func get_type_of_enemy():
	return UnitType.FOLLOWER


func _on_Cursor_confirm_issued(pos):
	if stage.selected_unit == self:
		if not stage.get_unit_at(pos):
			position = pos
			stage.deselect_unit()
	elif stage.selected_unit == null and pos == position:
		stage.select_unit(self)


func _on_Cursor_cancel_issued(pos):
	if stage.selected_unit == self:
		stage.deselect_unit()


func tick():
	.tick()
	move()


###############################################################################
#        Movement	                                                          #
###############################################################################


var target = null


export var base_movement = [0, 1, 0, 1]
export(Array, Resource) var traversable = []


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
	
	var movement = get_stat_after_statuses("movement", base_movement)
	movement = movement[(stage.cur_tick - 1) % len(movement)]
	
	var new_pos = position
	
	if len(path) > movement:
		new_pos = path[movement]
		var unit_at_new_pos = stage.get_unit_at(new_pos)
		
		while unit_at_new_pos and unit_at_new_pos != self:
			if unit_at_new_pos == target:
				target.take_damage()
				unit_at_new_pos = null
				die()
			else:
				movement -= 1
				new_pos = path[movement]
				unit_at_new_pos = stage.get_unit_at(new_pos)
		
		position = new_pos
