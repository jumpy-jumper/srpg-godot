extends Control


func update_ui(unit: Unit) -> void:
	# Update initiative label
	if unit.get_ini() > 0:
		if unit.ini_bonus > 1:
			$"Initiative".modulate = Color.lightgreen
		else:
			$"Initiative".modulate = Color.white
	else:
		$"Initiative".modulate = Color.deeppink

	$"Initiative".text = str(unit.get_ini()) if unit.get_ini() > 0 else "í ½í»‡í ½í»‡í ½í»‡-"

	# Update health label
	match unit.health:
		Unit.HealthLevels.HEALTHY:
			$"Health".text = ""
		Unit.HealthLevels.WOUNDED:
			$"Health".text = "-1"
			$"Health".modulate = Color.deeppink
		Unit.HealthLevels.CRIPPLED:
			$"Health".text = "-2"
			$"Health".modulate = Color.red
		Unit.HealthLevels.UNCONSCIOUS:
			$"Health".text = "-3"
			$"Health".modulate = Color.crimson
