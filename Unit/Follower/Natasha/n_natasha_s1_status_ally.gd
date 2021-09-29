extends Status


func tick():
	var unit = $"../.."
	unit.apply_damage(ceil(unit.get_stat("max_hp") * 0.03), unit.DamageType.RECOVERY)
	.tick()
