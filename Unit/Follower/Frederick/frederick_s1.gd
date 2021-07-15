extends Skill


func activate():
	.activate()
	unit.apply_healing(ceil(unit.get_stat("max_hp", unit.base_max_hp) * 0.07))
