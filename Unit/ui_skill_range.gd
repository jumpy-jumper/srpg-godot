extends RangeIndicator


export(Color) var inactive_color = Color.black
export(Color) var active_color = Color.black
export(Color) var marked_color = Color.purple


func _process(_delta):
	if len(unit.get_node("Skills").get_children()) > 0:
		var skill_active = false
		var skill = unit.get_first_activatable_skill()
		if skill and skill.is_active():
			skill_active = true
		
		var color = active_color if skill_active else inactive_color
		if unit.marked:
			color = marked_color
		
		update_range(unit.get_attack_range(), color)
