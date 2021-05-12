extends ProgressBar


onready var unit = get_parent().get_parent()


func _process(delta):
	value = float(unit.hp) / unit.max_hp * 100
	if unit is Enemy:
		visible = value != 100
