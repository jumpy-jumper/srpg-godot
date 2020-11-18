extends CanvasLayer


var cur_unit = null


func _process(_delta):
	if cur_unit:
		$"Unit Hover Panel".visible = true
		$"Unit Hover Panel/Unit Name".text = cur_unit.name
	else:
		$"Unit Hover Panel".visible = false
