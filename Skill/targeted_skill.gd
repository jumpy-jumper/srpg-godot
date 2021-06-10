extends Skill
class_name TargetedSkill


###############################################################################
#        Range logic                                                          #
###############################################################################


export(Array) var skill_range = [Vector2(0, 0)]


func get_skill_range():
	var ret = skill_range
	for status in unit.get_node("Statuses").get_children():
		if status.stat_overwrites.has("range"):
			ret = status.stat_overwrites["range"]
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
	var state = .get_state()
	state["skill_range"] = var2str(skill_range)
	state["target_count"] = target_count
	state["targeting_priority"] = targeting_priority
	return state


func load_state(state):
	.load_state(state)
	skill_range = str2var(state["skill_range"])
