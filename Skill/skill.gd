extends Node
class_name Skill


onready var unit = $"../.."


###############################################################################
#        Activation logic                                                     #
###############################################################################


enum Activation { NONE, TICK, DEPLOYMENT, SP_MANUAL, SP_AUTO }


export(Activation) var activation = Activation.NONE


var active = false


func _ready():
	if activation == Activation.DEPLOYMENT:
		activate()


func tick():
	if activation == Activation.TICK:
		activate()
		deactivate()


func activate():
	active = true
	add_statuses()


func deactivate():
	active = false
	remove_statuses()


###############################################################################
#        Status infliction logic                                              #
###############################################################################


export(Array, PackedScene) var statuses = []


var status_cache = []


func add_statuses():
	for status in statuses:
		status = status.instance()
		unit.get_node("Statuses").add_child(status)
		status_cache.append(status)


func remove_statuses():
	for status in unit.get_node("Statuses").get_children():
		if status in status_cache:
			status.queue_free()
			status_cache.erase(status)


###############################################################################
#        Range logic                                                          #
###############################################################################


export(Array) var skill_range = [Vector2(0, 0)]


func get_skill_range():
	var ret = skill_range
	
	for status in unit.get_node("Statuses").get_children():
		if status.stat_overwrites.has("range"):
			ret = status.stat_overwrites["range"]
	
	if unit.get_type_of_self() == unit.UnitType.FOLLOWER:	
		var rotated = []
		for pos in ret:
			rotated.append(pos.rotated(deg2rad(unit.facing)).round())
		return rotated
			
	return ret


func get_units_in_range_of_type(unit_type):
	var ret = []
	for pos in get_skill_range():
		var u = unit.stage.get_unit_at(unit.position + pos * unit.stage.get_cell_size())
		if u and u.get_type_of_self() == unit_type:
			ret.append(u)
	return ret


###############################################################################
#        Targeting logic                                                      #
###############################################################################


enum TargetingPriority { CLOSEST, LOWEST_HP_PERCENTAGE }


export var target_count = 1
export(TargetingPriority) var targeting_priority = TargetingPriority.CLOSEST


func select_targets(units):
	var ret = []
		
	match targeting_priority:
		TargetingPriority.CLOSEST:
			units.sort_custom(self, "distance_comparison") 
		TargetingPriority.LOWEST_HP_PERCENTAGE:
			units.sort_custom(self, "lowest_hp_percentage_comparison")
	
	for i in range(min(target_count, len(units))):
		ret.append(units[i])
	
	return ret


func distance_comparison(a, b):
	return abs((a.position - unit.position).length_squared()) < abs((b.position - unit.position).length_squared())


func lowest_hp_percentage_comparison(a, b):
	return float(a.hp) / a.base_max_hp < float(b.hp) / b.base_max_hp


###############################################################################
#        State logic                                                          #
###############################################################################


func get_state():
	var state = {
		"node_name" : name,
		"script_path" : get_script().get_path()
	}
	state["skill_range"] = var2str(skill_range)
	state["target_count"] = target_count
	state["targeting_priority"] = targeting_priority
	return state


func load_state(state):
	for v in state.keys():
		set(v, state[v])
	name = state["node_name"]
	skill_range = str2var(state["skill_range"])
