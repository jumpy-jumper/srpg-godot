extends Button


export(Color) var selected_color = Color.lightpink
export(Color) var deselected_color = Color.black

onready var base_alpha = $CooldownPanel.modulate.a

var stage = null
var follower_group = null

func get_cur_unit():
	return follower_group[stage.get_selected_summoner().wind] if follower_group.has(stage.get_selected_summoner().wind) else null

func initialize_panel(follower_group):
	self.follower_group = follower_group
	var unit = follower_group.values()[0]

	$Mugshot.texture = unit.portrait
	$Mugshot.region_rect.position = unit.mugshot_top_left
	$CooldownPanel.modulate.a = base_alpha * 0.5
	$CooldownPanel/Cooldown.text = ""
	$Cost.text = str(unit.get_stat("cost", unit.base_cost))


func update_panel():
	if follower_group == null:
		return
	
	$Border.modulate = selected_color if stage.selected_follower_index == int(name)-1 else deselected_color
	
	var first_unit = follower_group.values()[0]
	var cur_unit = get_cur_unit()
	
	if first_unit.get_alive_in_group():
		$CooldownPanel.visible = true
		$CooldownPanel.modulate.a = base_alpha
		$CooldownPanel/Cooldown.text = first_unit.Wind.keys()[first_unit.get_alive_in_group().wind][0]
	else:
		if cur_unit:
			$Level.text = "L" + str(cur_unit.get_stat("level", cur_unit.base_level))
			$Cost.text = str(cur_unit.get_stat("cost", cur_unit.base_cost))
			$Cost.modulate = Color.lightpink if cur_unit.summoner.faith < cur_unit.get_stat("cost", cur_unit.base_cost) else Color.white
		if first_unit.cooldown > 0:
			$CooldownPanel.visible = true
			$CooldownPanel.modulate.a = base_alpha
			$CooldownPanel/Cooldown.text = str(first_unit.cooldown)
		elif cur_unit and cur_unit.get_stat("cost", cur_unit.base_cost) <= cur_unit.summoner.faith:
			$CooldownPanel.visible = false
			$CooldownPanel/Cooldown.text = ""
		else:
			$CooldownPanel.visible = true
			$CooldownPanel.modulate.a = base_alpha * 0.5
			$CooldownPanel/Cooldown.text = ""


func _on_Follower_Panel_gui_input(event):
	if event is InputEventMouseButton and not event.pressed:
		if stage.can_select_follower_ui():
			if event.button_index == BUTTON_LEFT:
				stage.selected_follower_index = int(name)-1
			elif event.button_index == BUTTON_RIGHT:
				stage.selected_follower_index = int(name)-1
				if stage.can_show_ui():
					yield(get_tree(), "idle_frame")
					yield(get_tree(), "idle_frame")
					# Why? Why do I need to idle for 2 frames? I don't know.
					if follower_group.has(stage.get_selected_summoner().wind):
						stage.show_unit_ui(get_cur_unit())
