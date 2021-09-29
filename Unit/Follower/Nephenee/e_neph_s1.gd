extends Skill


func tick():
	if is_active():
		unit.apply_damage(ceil(unit.get_stat("max_hp") * 0.4), unit.DamageType.SHIELD_DAMAGE)
	.tick()


func activate():
	.activate()
	unit.apply_damage(floor(unit.get_stat("max_hp") * 1.6), unit.DamageType.SHIELD)
