extends Label

func _process(delta):
	var health = get_parent().health
	match health:
		Unit.health_levels.healthy:
			text = ""
		Unit.health_levels.wounded:
			text = "-1"
			modulate = Color.deeppink
		Unit.health_levels.crippled:
			text = "-2"
			modulate = Color.red
		Unit.health_levels.unconscious:
			text = "-3"
			modulate = Color.crimson