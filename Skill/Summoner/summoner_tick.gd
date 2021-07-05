extends Skill


export var base_recovery = [1, 1, 1, 1]


func activate():
	.activate()
	unit.faith = min(unit.get_stat_after_statuses("faith_recovery", base_recovery)[(unit.stage.cur_tick - 1) % len(base_recovery)] + unit.faith, \
		unit.get_stat_after_statuses("max_faith", unit.base_max_faith))
