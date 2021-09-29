extends Skill


func tick():
	if is_active():
		unit.apply_damage(ceil(unit.get_stat("max_hp") * 0.07), unit.DamageType.RECOVERY)
	.tick()
