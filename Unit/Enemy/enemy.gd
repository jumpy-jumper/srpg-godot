class_name Enemy
extends Unit


var gate = null
var path = []


func get_type_of_self():
	return UnitType.ENEMY


func get_type_of_enemy():
	return UnitType.FOLLOWER


func _process(_delta):
	var path = ([] + gate.path) if gate else (stage.get_path_to_target(position, stage.get_selected_summoner().position, traversable))


func _on_Cursor_confirm_issued(pos):
	._on_Cursor_confirm_issued(pos)
	if pos == position:
		marked = not marked


###############################################################################
#        Movement	                                                          #
###############################################################################


export var base_movement = [0, 1, 0, 1]
export(Array, Resource) var traversable = []


var movement = 0


func move():	
	var target = stage.get_selected_summoner()		
	var path = ([] + gate.path) if gate else (stage.get_path_to_target(position, stage.get_selected_summoner().position, traversable))
	
	while (path[0] != position):
		path.pop_front()
	
	var leftover_movement = movement
	
	var newpos = position
	
	for i in range(movement + 1):
		if i < len(path):
			var unit = stage.get_unit_at(path[i])
			if unit:
				if unit.get_type_of_self() == UnitType.SUMMONER:
					unit.apply_damage()
					die()
					break
				elif unit.get_type_of_self() == UnitType.FOLLOWER:
					continue
				elif unit.get_type_of_self() == UnitType.ENEMY:
					continue
			newpos = path[i]
			leftover_movement = movement - i

	var movement_array = get_stat("movement", base_movement)
	var this_tick_movement = movement_array[(stage.cur_tick) % len(movement_array)]
	
	if movement >= this_tick_movement:
		movement = leftover_movement + min(this_tick_movement, 1)
	else:
		movement = leftover_movement + this_tick_movement
	
	var oldpos = position
	position = newpos


###############################################################################
#        Block logic                                                          #
###############################################################################


var blocker = null


###############################################################################
#        State                                                                #
###############################################################################


func get_state():
	var ret = .get_state()	
	ret["movement"] = movement
	return ret


func load_state(state):
	.load_state(state)
	movement = state["movement"]
