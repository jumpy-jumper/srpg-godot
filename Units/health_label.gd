extends Label


func _process(_delta) -> void:
	var health: int = get_parent().health
	match health:
		Unit.HealthLevels.HEALTHY:
			text = ""
		Unit.HealthLevels.WOUNDED:
			text = "-1"
			modulate = Color.deeppink
		Unit.HealthLevels.CRIPPLED:
			text = "-2"
			modulate = Color.red
		Unit.HealthLevels.UNCONSCIOUS:
			text = "-3"
			modulate = Color.crimson
