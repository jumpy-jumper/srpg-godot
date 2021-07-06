extends RangeIndicator


export(Color) var inactive_color = Color.black
export(Color) var active_color = Color.black


func _process(_delta):
	if len(unit.get_node("Skills").get_children()) > 0:
		var skill_active = false
		for skill in unit.get_node("Skills").get_children():
			if skill.is_active():
				skill_active = true
				break
		update_range(unit.get_node("Skills").get_children()[0].get_skill_range(), \
			active_color if skill_active else inactive_color)
