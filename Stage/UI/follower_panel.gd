extends Node2D


func update_unit(unit):
	$Mugshot.texture = unit.portrait
	$Mugshot.region_rect.position = unit.mugshot_top_left
	$Cost.text = str(unit.cost)
