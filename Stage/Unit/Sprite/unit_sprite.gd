extends AnimatedSprite

onready var _unit : Unit = $"../"

func _process(_delta: float) -> void:
	animation = "blue_idle" if _unit.type == Unit.UnitType.ALLY else "red_idle"
