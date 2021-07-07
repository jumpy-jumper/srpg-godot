extends Node
class_name Skill


onready var unit = $"../.."

export(String, MULTILINE) var description = ""


###############################################################################
#        Activation logic                                                     #
###############################################################################


enum Activation { NONE, EVERY_TICK, DEPLOYMENT, SP_MANUAL, SP_AUTO }
export(Activation) var activation = Activation.NONE
export var base_skill_cost = 15
export var base_skill_initial_sp = 10
export var base_skill_duration = 30


var sp = base_skill_initial_sp
var ticks_left = 0


func is_active():
	return ticks_left > 0


func is_available():
	return activation == Activation.SP_MANUAL \
		and sp == unit.get_stat("skill_cost", base_skill_cost) \
		and not is_active()


func tick():
	if activation == Activation.EVERY_TICK:
		activate()
		deactivate()
	elif activation == Activation.SP_MANUAL or activation == Activation.SP_AUTO:
		if not is_active():
			var sp_cost = unit.get_stat("skill_cost", base_skill_cost)
			sp = min(sp + 1, sp_cost)
			if activation == Activation.SP_AUTO and sp == sp_cost:
				activate()
		else:
			ticks_left = max(0, ticks_left - 1)
			if ticks_left == 0:
				deactivate()


func activate():
	if activation != Activation.NONE and activation != Activation.EVERY_TICK:
		ticks_left = unit.get_stat("skill_duration", base_skill_duration)
		update_statuses()
	unit.emit_signal("acted", unit)


func deactivate():
	sp = 0
	ticks_left = 0
	update_statuses()


func initialize():
	sp = unit.get_stat("skill_initial_sp", base_skill_initial_sp)
	ticks_left = 0
	if activation == Activation.DEPLOYMENT:
		activate()


###############################################################################
#        Status infliction logic                                              #
###############################################################################


export(Array, PackedScene) var statuses = []


var status_cache = []


func update_statuses():
	remove_statuses()
	if is_active():
		add_statuses()


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


export(Array) var base_skill_range = [Vector2(0, 0)]


func get_skill_range():
	return unit.get_stat("skill_range", base_skill_range)


###############################################################################
#        Targeting logic                                                      #
###############################################################################


enum TargetingPriority { CLOSEST_TO_SELF, LOWEST_HP_PERCENTAGE, CLOSEST_TO_SUMMONER }


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
	
	for i in range(min(unit.get_stat("target_count", base_target_count), len(units))):
		ret.append(units[i])
	
	return ret


func closest_to_self_comparison(a, b):
	return abs((a.position - unit.position).length_squared()) < abs((b.position - unit.position).length_squared())


func lowest_hp_percentage_comparison(a, b):
	return float(a.hp) / a.get_stat("max_hp", a.base_max_hp) <\
		float(b.hp) / b.get_stat("max_hp", b.base_max_hp)


func closest_to_summoner_comparison(a, b):
	var summ = unit.stage.summoners_cache[0]
	return abs((a.position - summ.position).length_squared()) < abs((b.position - summ.position).length_squared())
