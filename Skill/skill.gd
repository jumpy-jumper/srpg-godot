extends Node
class_name Skill


onready var unit = $"../.."

export(String, MULTILINE) var description = ""

func is_basic_attack():
	return false

###############################################################################
#        Activation logic                                                     #
###############################################################################


enum Activation { PASSIVE, EVERY_TICK, DEPLOYMENT, SP_MANUAL, SP_AUTO, TURN_START }
export(Activation) var activation = Activation.PASSIVE
export var base_skill_cost = 15
export var base_skill_initial_sp = 10
export var base_skill_duration = 30


onready var sp = base_skill_initial_sp
var ticks_left = 0


func is_active():
	return ticks_left > 0


func is_available():
	return (activation == Activation.SP_MANUAL or activation == Activation.SP_AUTO) \
		and sp >= unit.get_stat("skill_cost", base_skill_cost) \
		and not is_active()


func tick():
	if activation == Activation.EVERY_TICK:
		activate()
		deactivate()
	else:
		if not is_active():
			var sp_cost = unit.get_stat("skill_cost", base_skill_cost)
			sp = 0 if activation == Activation.DEPLOYMENT else min(sp + 1, sp_cost)
		else:
			ticks_left = max(0, ticks_left - 1)
			if ticks_left == 0:
				deactivate()


func activate():
	if activation != Activation.PASSIVE and activation != Activation.EVERY_TICK:
		ticks_left = unit.get_stat("skill_duration", base_skill_duration)
		add_statuses()
		if activation == Activation.SP_MANUAL:
			unit.stage.append_state()
		if ticks_left == 0:
			deactivate()


func deactivate():
	sp = 0
	ticks_left = 0


func initialize():
	sp = unit.get_stat("skill_initial_sp", base_skill_initial_sp)
	ticks_left = 0


###############################################################################
#        Status infliction logic                                              #
###############################################################################


export(Array, PackedScene) var statuses_self = []
export(Array, PackedScene) var statuses_allies_in_attack_range = []
export(Array, PackedScene) var statuses_all_allies = []


func add_statuses():
	for status in statuses_self:
		var this_status = status.instance()
		this_status.issuer_unit = unit
		this_status.issuer_name = name
		unit.get_node("Statuses").add_child(this_status)
	for status in statuses_allies_in_attack_range:
		var targets = unit.get_units_in_range_of_type(unit.get_attack_range(), unit.get_type_of_self())
		for target in targets:
			var this_status = status.instance()
			this_status.issuer_unit = unit
			this_status.issuer_name = name
			target.get_node("Statuses").add_child(this_status)
	for status in statuses_all_allies:
		var targets = unit.stage.get_units_of_type(unit.get_type_of_self())
		for target in targets:
			var this_status = status.instance()
			this_status.issuer_unit = unit
			this_status.issuer_name = name
			target.get_node("Statuses").add_child(this_status)


# Yikes
# Might wanna figure out a different way to do this later on
func remove_statuses():
	for status in unit.stage.get_all_statuses():
		if status.issuer_unit == unit and status.issuer_name == name:
			status.free()


###############################################################################
#        Range logic                                                          #
###############################################################################


export(Array) var base_skill_range = []


###############################################################################
#        Targeting logic                                                      #
###############################################################################


enum TargetingPriority { CLOSEST_TO_SELF, LOWEST_HP_PERCENTAGE, CLOSEST_TO_SUMMONER, LAST_SUMMONED, FIRST_SUMMONED }


export var base_target_count = 1
export(TargetingPriority) var targeting_priority = TargetingPriority.CLOSEST_TO_SUMMONER


func select_targets(units):
	var ret = []
		
	match targeting_priority:
		TargetingPriority.CLOSEST_TO_SELF:
			units.sort_custom(self, "closest_to_self_comparison") 
		TargetingPriority.LOWEST_HP_PERCENTAGE:
			units.sort_custom(self, "lowest_hp_percentage_comparison")
		TargetingPriority.CLOSEST_TO_SUMMONER:
			units.sort_custom(self, "closest_to_summoner_comparison")
		TargetingPriority.LAST_SUMMONED:
			units.sort_custom(self, "last_summoned_comparison")
		TargetingPriority.FIRST_SUMMONED:
			units.sort_custom(self, "first_summoned_comparison")
	
	for i in range(min(unit.get_stat("target_count", base_target_count), len(units))):
		ret.append(units[i])
	
	return ret


func is_blocking_or_blocked(u):
	if unit.get_type_of_self() == unit.UnitType.FOLLOWER:
		return u in unit.blocked
	else:
		return unit.blocker == u


func closest_to_self_comparison(a, b):
	if is_blocking_or_blocked(a) and not is_blocking_or_blocked(b):
		return true
	elif is_blocking_or_blocked(b) and not is_blocking_or_blocked(a):
		return false
	return abs((a.position - unit.position).length_squared()) < abs((b.position - unit.position).length_squared())


func lowest_hp_percentage_comparison(a, b):
	if is_blocking_or_blocked(a) and not is_blocking_or_blocked(b):
		return true
	elif is_blocking_or_blocked(b) and not is_blocking_or_blocked(a):
		return false
	return float(a.hp) / a.get_stat("max_hp", a.base_max_hp) <\
		float(b.hp) / b.get_stat("max_hp", b.base_max_hp)


func closest_to_summoner_comparison(a, b):
	if is_blocking_or_blocked(a) and not is_blocking_or_blocked(b):
		return true
	elif is_blocking_or_blocked(b) and not is_blocking_or_blocked(a):
		return false
	var summ = unit.stage.get_selected_summoner()
	return abs((a.position - summ.position).length_squared()) < abs((b.position - summ.position).length_squared())


func last_summoned_comparison(a, b):
	if is_blocking_or_blocked(a) and not is_blocking_or_blocked(b):
		return true
	elif is_blocking_or_blocked(b) and not is_blocking_or_blocked(a):
		return false
	return a.stage.summoned_order.find(a.name) > b.stage.summoned_order.find(b.name)


func first_summoned_comparison(a, b):
	if is_blocking_or_blocked(a) and not is_blocking_or_blocked(b):
		return true
	elif is_blocking_or_blocked(b) and not is_blocking_or_blocked(a):
		return false
	return a.stage.summoned_order.find(a.name) > b.stage.summoned_order.find(b.name)



###############################################################################
#        State                                                                #
###############################################################################


func get_state():
	var ret = {}
	ret["script"] = get_script().get_path()
	ret["name"] = name
	ret["description"] = description
	ret["activation"] = activation
	ret["base_skill_cost"] = base_skill_cost
	ret["base_skill_initial_sp"] = base_skill_initial_sp
	ret["base_skill_duration"] = base_skill_duration
	ret["sp"] = sp
	ret["ticks_left"] = ticks_left
	ret["statuses_self"] = var2str(statuses_self)
	ret["statuses_allies_in_attack_range"] = var2str(statuses_allies_in_attack_range)
	ret["statuses_all_allies"] = var2str(statuses_all_allies)
	ret["base_skill_range"] = base_skill_range
	ret["base_target_count"] = base_target_count
	ret["targeting_priority"] = targeting_priority	
	return ret


func load_state(state):
	name = state["name"]
	description = state["description"]
	activation = state["activation"]
	base_skill_cost = state["base_skill_cost"]
	base_skill_initial_sp = state["base_skill_initial_sp"]
	base_skill_duration = state["base_skill_duration"]
	sp = state["sp"]
	ticks_left = state["ticks_left"]
	statuses_self = str2var(state["statuses_self"])
	statuses_allies_in_attack_range = str2var(state["statuses_allies_in_attack_range"])
	statuses_all_allies = str2var(state["statuses_all_allies"])
	base_skill_range = state["base_skill_range"]
	base_target_count = state["base_target_count"]
	targeting_priority = state["targeting_priority"]
