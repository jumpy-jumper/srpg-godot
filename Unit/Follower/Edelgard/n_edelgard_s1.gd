extends Skill


func tick():
	if is_active():
		unit.apply_healing(ceil(unit.get_stat("max_hp") * 0.07))
	.tick()
