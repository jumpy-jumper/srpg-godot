extends Status


func tick():
	var unit = $"../.."
	unit.apply_healing(ceil(unit.get_stat("max_hp") * 0.03))
	.tick()
