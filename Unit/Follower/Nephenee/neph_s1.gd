extends Skill


func tick():
	if is_active():
		unit.apply_damage(ceil(unit.get_stat("max_hp", unit.base_max_hp) * 0.4), unit.DamageType.SHIELD_DAMAGE)
	.tick()


func activate():
	.activate()
	unit.apply_shield(floor(unit.get_stat("max_hp", unit.base_max_hp) * 1.6))
