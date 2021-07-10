extends ProgressBar


onready var unit = get_parent().get_parent()


onready var base_left = margin_left
onready var width = margin_right - margin_left


func _process(delta):
	value = float(unit.hp) / unit.get_stat("max_hp", unit.base_max_hp) * 100
	
	var percentage = float(unit.hp) / (unit.hp + unit.shield)
	margin_right = base_left + width * percentage
	
	if unit is Enemy:
		visible = value != 100
