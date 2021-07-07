class_name Enemy
extends Unit


var gate = null


func get_type_of_self():
	return UnitType.ENEMY


func get_type_of_enemy():
	return UnitType.FOLLOWER


func _ready():
	alive = true
	var movement_array = get_stat("movement", base_movement)
	movement = movement_array[0]


func _process(_delta):
	._process(_delta)


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


export var base_movement = [0, 1, 0, 1]
export(Array, Resource) var traversable = []


var movement = 0


func get_path_to_target():
	var astar = stage.get_astar_graph(traversable)

	var target = stage.summoners_cache[0] # TEMPORARY
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
	
	var leftover_movement = movement
	
	for i in range(movement + 1):
		if i < len(path):
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
	
	var movement_array = get_stat("movement", base_movement)
	movement = leftover_movement + movement_array[(stage.cur_tick) % len(movement_array)]


###############################################################################
#        Block logic                                                          #
###############################################################################

var blocker = null
