class_name Enemy
extends Unit


export var base_mov = 3


func get_unit_type():
	return UnitType.ENEMY


func _on_Cursor_confirm_issued(pos):
	._on_Cursor_confirm_issued(pos)
	var unit = stage.get_unit_at(pos)
	
	if stage.selected_unit == self:
		if unit != null:
			if unit is PlayerUnit:
				var dmg = (base_atk - unit.base_def) if unit is Follower else 1
				unit.take_damage(dmg)
				emit_signal("acted", self, "attacked " + unit.unit_name \
					+ " for " + str(dmg))
				stage.selected_unit = null
		else:
			position = pos
			emit_signal("acted", self, "moved to " + str(pos))
			stage.deselect()
	elif stage.selected_unit == null and pos == position:
		stage.selected_unit = self
	
	
func _on_Cursor_cancel_issued(pos):
	._on_Cursor_cancel_issued(pos)
	if stage.selected_unit == self:
		stage.deselect()
