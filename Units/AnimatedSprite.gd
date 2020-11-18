extends AnimatedSprite

func _process(delta):
	if get_parent().done:
		animation = "grey_idle"
	else:
		animation = "blue_idle" if get_parent().type == Unit.unit_type.ally else "red_idle"