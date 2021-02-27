extends Control


func _process(delta):
	var unit = $".."

	# Update initiative label
	if unit.ini > 0:
		$"Initiative".modulate = Color.white
	else:
		$"Initiative".modulate = Color.deeppink

	$"Initiative".text = str(unit.ini) if unit.ini > 0 else "í ½í»‡í ½í»‡í ½í»‡-"

	# Update health label
	$Health.text = str(unit.hp)
