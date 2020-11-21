class_name UnitPanel
extends Node2D


var current = false
var cur_unit = null


func _process(_delta):
	if cur_unit:
		visible = true
		if $"Unit Sprite".frames != cur_unit.get_node("Sprite").frames:
			$"Unit Sprite".frames = cur_unit.get_node("Sprite").frames
		if $"Unit Sprite".animation != cur_unit.get_node("Sprite").animation:
			$"Unit Sprite".animation = cur_unit.get_node("Sprite").animation
		$"Initiative Label".text = cur_unit.get_node("UI/Initiative").text
		$"Initiative Label".modulate = cur_unit.get_node("UI/Initiative").modulate
		$"Health Label".text = cur_unit.get_node("UI/Health").text
		$"Health Label".modulate = cur_unit.get_node("UI/Health").modulate
		$"Current".visible = current
	else:
		visible = false
