extends Button


export(Color) var selected_color = Color.lightpink
export(Color) var deselected_color = Color.black


var unit = null

onready var base_alpha = $CooldownPanel.modulate.a

func update_unit(unit, selected):
	self.unit = unit
	$Mugshot.texture = unit.portrait
	$Mugshot.region_rect.position = unit.mugshot_top_left
	$Level.text = "L" + str(unit.get_stat("level", unit.base_level))
	$Cost.text = str(unit.get_stat("cost", unit.base_cost))
	$Cost.modulate = Color.lightpink if unit.summoner.faith < unit.get_stat("cost", unit.base_cost) else Color.white
	$Border.modulate = selected_color if selected else deselected_color
	
	if unit.alive:
		$CooldownPanel.visible = true
		$CooldownPanel.modulate.a = base_alpha
		$CooldownPanel/Cooldown.text = "OUT"
	else:
		if unit.cooldown > 0:
			$CooldownPanel.visible = true
			$CooldownPanel.modulate.a = base_alpha
			$CooldownPanel/Cooldown.text = str(unit.cooldown)
		elif unit.get_stat("cost", unit.base_cost) <= unit.summoner.faith:
			$CooldownPanel.visible = false
			$CooldownPanel/Cooldown.text = ""
		else:
			$CooldownPanel.visible = true
			$CooldownPanel.modulate.a = base_alpha * 0.5
			$CooldownPanel/Cooldown.text = ""


func _on_Follower_Panel_gui_input(event):
	if event is InputEventMouseButton and not event.pressed and unit:
		match event.button_index:
			BUTTON_LEFT:
				if unit.stage.can_select_follower_ui():
					var follower_index = unit.stage.get_selected_summoner().followers.find(unit)
					unit.stage.selected_follower_index = follower_index
			BUTTON_RIGHT:
				if unit.stage.can_select_follower_ui() and unit.stage.can_show_ui():
					yield(get_tree(), "idle_frame")
					yield(get_tree(), "idle_frame")
					# Why? Why do I need to idle for 2 frames? I don't know.
					unit.stage.show_unit_ui(unit)
					var follower_index = unit.stage.get_selected_summoner().followers.find(unit)
					unit.stage.selected_follower_index = follower_index
