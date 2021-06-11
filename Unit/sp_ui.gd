extends ProgressBar


onready var unit = get_parent().get_parent()


export var skill_inactive_color = Color.cyan
export var skill_active_color = Color.lightsalmon


func _process(delta):
	var activatable_skills = []
	for skill in unit.get_node("Skills").get_children():
		if skill.activation == skill.Activation.SP_AUTO \
			or skill.activation == skill.Activation.SP_MANUAL:
				activatable_skills.append(skill)
	if len(activatable_skills) == 0:
		visible = false
	else:
		visible = true
		var skill = activatable_skills[0]
		if not skill.active:
			value = float(skill.sp) / skill.get_cost() * 100
			get("custom_styles/fg").set_bg_color(skill_inactive_color)
		else:
			value = float(skill.ticks_left) / skill.get_duration() * 100
			get("custom_styles/fg").set_bg_color(skill_active_color)
