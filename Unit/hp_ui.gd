extends ProgressBar


onready var unit = get_parent().get_parent()


func _process(delta):
	value = float(unit.hp) / unit.get_stat("max_hp", unit.base_max_hp) * 100
	if unit is Enemy:
		visible = value != 100
