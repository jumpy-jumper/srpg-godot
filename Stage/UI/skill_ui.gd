extends Control


var skill = null


func update_skill(skill, unit):
	$Button.disabled = true
	
	if skill == null:
		visible = false
		return
	
	self.skill = skill
	visible = true
	var skill_ui = self
	
	var button_label = skill_ui.get_node("Button/Label")
	
	if not skill.is_active():
		button_label.text = ""
		if skill.activation == skill.Activation.SP_MANUAL:
			skill_ui.get_node("Button").disabled = false
			button_label.text += "USE\n"
		if skill.activation == skill.Activation.SP_MANUAL \
			or skill.activation == skill.Activation.SP_AUTO:
				button_label.text += "(" + str(skill.sp) + "/"
				button_label.text += str(unit.get_stat("skill_cost", skill.base_skill_cost)) + ")"
	else:
		button_label.text = "ACTIVE"
	
	skill_ui.get_node("Button").visible = button_label.text != ""
	
	var skill_label = skill_ui.get_node("Description Label")
	
	skill_label.text = "[" + skill.name + "]"
	match skill.activation:
		skill.Activation.EVERY_TICK:
			skill_label.text += "\n[EVERY ROUND]"
		skill.Activation.DEPLOYMENT:
			skill_label.text += "\n[ON DEPLOYMENT]"
		skill.Activation.SP_MANUAL:
			skill_label.text += "\n[MANUAL]"
		skill.Activation.SP_AUTO:
			skill_label.text += "\n[AUTO]"
		skill.Activation.NONE:
			skill_label.text += "\n[PASSIVE]"
	if skill.activation == skill.Activation.SP_MANUAL \
		or skill.activation == skill.Activation.SP_AUTO:
			skill_label.text += " [INITIAL " + str(unit.get_stat("skill_initial_sp", skill.base_skill_initial_sp)) + "]"
			skill_label.text += " [COST " + str(unit.get_stat("skill_cost", skill.base_skill_cost)) + "]"
	if skill.activation == skill.Activation.SP_MANUAL \
		or skill.activation == skill.Activation.SP_AUTO \
		or skill.activation == skill.Activation.DEPLOYMENT:
			var duration = unit.get_stat("skill_duration", skill.base_skill_duration)
			skill_label.text += " [DURATION " + (str(duration) if duration < 1982371 else "∞") + "]"
	
	skill_label.text += "\n" + skill.description


signal skill_activation_requested(skill)


func _on_Button_pressed():
	emit_signal("skill_activation_requested", skill)
