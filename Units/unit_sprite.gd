extends AnimatedSprite

func _process(_delta):
	animation = "blue_idle" if get_parent().type == Unit.unit_type.ally else "red_idle"
