class_name Enemy
extends Unit


func get_type_of_self():
	return UnitType.ENEMY


func get_type_of_enemy():
	return UnitType.FOLLOWER


func _ready():
	alive = true


func _process(_delta):
	._process(_delta)
	$Blocked.visible = blocker != null


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
	if alive:
		move()
	if blocker and not blocker.alive:
		blocker = null

func die():
	.die()
	if blocker:
		blocker.blocked.erase(self)


###############################################################################
#        Movement	                                                          #
###############################################################################


var target = null


export var base_movement = [0, 1, 0, 1]
export(Array, Resource) var traversable = []


var banked_movement = 0


func get_path_to_target():
	var astar = stage.get_astar_graph(traversable)

	target = stage.summoners_cache[0] # TEMPORARY
	var path = astar.get_point_path(astar.get_closest_point(stage.terrain.world_to_map(position)), 
		astar.get_closest_point(stage.terrain.world_to_map(target.position)))

	var ret = []
	for v in path:
		ret.append(v * stage.get_cell_size())
	return ret


func move():
	if blocker != null:
		return

	var path = get_path_to_target()
	
	var movement = get_stat_after_statuses("movement", base_movement)
	movement = movement[(stage.cur_tick - 1) % len(movement)]
	movement += banked_movement
	banked_movement = 0
	
	var leftover_movement = movement
	
	for i in range(movement + 1):
		var unit = stage.get_unit_at(path[i])
		if unit:
			if unit.get_type_of_self() == UnitType.SUMMONER:
				unit.take_damage()
				die()
				break
			elif unit.get_type_of_self() == UnitType.FOLLOWER:
				continue
			elif unit.get_type_of_self() == UnitType.ENEMY:
				continue
		position = path[i]
		leftover_movement = movement - i
	
	banked_movement += leftover_movement


###############################################################################
#        Block logic                                                          #
###############################################################################

var blocker = null
