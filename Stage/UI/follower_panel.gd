extends Button


export(Color) var selected_color = Color.lightpink
export(Color) var deselected_color = Color.black


var unit = null


func update_unit(unit, selected):
	self.unit = unit
	$Mugshot.texture = unit.portrait
	$Mugshot.region_rect.position = unit.mugshot_top_left
	$Cost.text = str(unit.get_stat("cost", unit.base_cost))
	$Cost.modulate = Color.lightpink if unit.summoner.faith < unit.get_stat("cost", unit.base_cost) else Color.white
	$Border.modulate = selected_color if selected else deselected_color
	$Cost.visible = not unit.alive
	$CooldownPanel.visible = unit.alive or unit.cooldown > 0
	$CooldownPanel/Cooldown.text = "OUT" if unit.cooldown == 0 else str(unit.cooldown)
	$CooldownPanel/Cooldown.modulate = Color.lightpink if unit.cooldown > 0 else Color.white


func _on_Follower_Panel_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				if unit.stage.can_select_follower_ui():
					var follower_index = unit.stage.get_selected_summoner().followers.find(unit)
					unit.stage.selected_follower_index = follower_index
			BUTTON_RIGHT:
				if unit.stage.can_select_follower_ui() and unit.stage.can_show_unit_ui():
					unit.stage.show_unit_ui(unit)
					var follower_index = unit.stage.get_selected_summoner().followers.find(unit)
					unit.stage.selected_follower_index = follower_index
