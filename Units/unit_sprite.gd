extends AnimatedSprite


func _process(_delta: float) -> void:
	animation = "blue_idle" if get_parent().type == Unit.UnitType.ALLY else "red_idle"
