extends AnimatedSprite


func _process(_delta):
	animation = "blue_idle" if get_parent().type == Unit.UnitType.ALLY else "red_idle"
