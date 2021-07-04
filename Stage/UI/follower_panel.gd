extends Node2D


export(Color) var selected_color = Color.lightpink
export(Color) var deselected_color = Color.black


func update_unit(unit, selected):
	$Mugshot.texture = unit.portrait
	$Mugshot.region_rect.position = unit.mugshot_top_left
	$Cost.text = str(unit.cost)
	$Border.modulate = selected_color if selected else deselected_color
	$Cost.visible = not unit.alive
	$CooldownPanel.visible = unit.alive
	$CooldownPanel/Cooldown.text = "OUT"
