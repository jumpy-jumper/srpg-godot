extends ProgressBar


onready var unit = get_parent().get_parent().get_parent()


export var skill_inactive_color = Color.cyan
export var skill_inactive_color_green_delta_per_charge = 0.25
export var skill_active_color = Color.lightsalmon


func _process(_delta):
	var skill = unit.get_first_activatable_skill()
	if skill:
		visible = true
		var fg = get("custom_styles/fg").duplicate()
		if not skill.is_active():
			var proportion = float(skill.sp) / skill.get_stat("skill_cost") * 100
			var sp_color = skill_inactive_color
			sp_color.g += skill_inactive_color_green_delta_per_charge
			var charging_color = skill_inactive_color
			var charging = proportion > 100
			while proportion > 100:
				proportion -= 100
				sp_color.g -= skill_inactive_color_green_delta_per_charge
				charging_color.g -= skill_inactive_color_green_delta_per_charge
			fg.set_bg_color(sp_color)

			value = 100 if charging else proportion
			
			var charge_fg = $Charge.get("custom_styles/fg").duplicate()
			charge_fg.set_bg_color(charging_color)
			$Charge.value = proportion
			$Charge.set("custom_styles/fg", charge_fg)
			$Charge.visible = true
		else:
			value = float(skill.ticks_left) / skill.get_stat("skill_duration") * 100
			fg.set_bg_color(skill_active_color)
			$Charge.visible = false
		set("custom_styles/fg", fg)
	else:
		visible = false
