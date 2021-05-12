extends ProgressBar


onready var unit = get_parent().get_parent()


func _process(delta):
	value = float(unit.sp) / unit.max_sp * 100
	if unit is Enemy:
		visible = value != 0
