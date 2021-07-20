extends ProgressBar


onready var unit = $"../../.."


export var skill_inactive_color = Color.cyan
export var skill_active_color = Color.lightsalmon


func _process(_delta):
	var skill = unit.get_first_activatable_skill()
	if skill:
		visible = true
		
		var fg = get("custom_styles/fg").duplicate()
		if not skill.is_active():
			value = float(skill.sp) / unit.get_stat("skill_cost", skill.base_skill_cost) * 100
			fg.set_bg_color(skill_inactive_color)
		else:
			value = float(skill.ticks_left) / unit.get_stat("skill_duration", skill.base_skill_duration) * 100
			fg.set_bg_color(skill_active_color)
		set("custom_styles/fg", fg)
	else:
		visible = false
