extends Control


onready var stage = $"../.."


func _on_Cursor_moved(pos):
	var unit = stage.get_unit_at(pos)
	
	if unit:
		if unit is Follower or unit is Enemy:
			visible = true
			$Name.text = unit.unit_name
			$Stats.text = "LV " + str(unit.base_level) \
				+ "\nATK " + str(unit.base_atk) \
				+ "\nDEF " + str(unit.base_def) \
				+ "\nRES " + str(unit.base_res)
			if unit is Enemy:
				$Stats.text += "\nMOV " + str(unit.base_mov)
	else:
		visible = false
