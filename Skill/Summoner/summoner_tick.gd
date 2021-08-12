extends Skill


export var base_recovery = [0, 0, 0, 0]


func activate():
	.activate()
	unit.faith = min(unit.get_stat("faith_recovery", base_recovery)[(unit.stage.cur_tick - 1) % len(base_recovery)] + unit.faith, \
		unit.get_stat("max_faith", unit.base_max_faith))
