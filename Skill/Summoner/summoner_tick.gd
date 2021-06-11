extends Skill


export var base_recovery = 2


func activate():
	.activate()
	unit.sp = min(base_recovery+unit.sp, unit.base_max_sp)
