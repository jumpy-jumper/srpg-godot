extends Skill


export var base_recovery = 2


func activate():
	.activate()
	unit.sp = min(unit.get_stat_after_statuses("summ_sp_recovery", base_recovery) + unit.sp, \
		unit.get_stat_after_statuses("max_sp", unit.base_max_sp))
