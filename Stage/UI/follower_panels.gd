extends Node2D


onready var stage = $"../.."

func _ready():
	for panel in get_children():
		panel.connect("mouse_entered", stage, "_on_UI_mouse_entered")
		panel.connect("mouse_exited", stage, "_on_UI_mouse_exited")
		#panel.connect("pressed", stage, "_on_follower_button_pressed", [panel])


func update_ui():
	visible = true

	var followers = stage.summoners_cache[0].followers
	
	var i = 0
	for panel in get_children():
		if i >= len(followers):
			panel.visible = false
		else:
			panel.visible = true
			var unit = stage.summoners_cache[0].followers[i]
			panel.update_unit(unit, i == stage.selected_follower_index)
		i += 1


func cost_comparison(a, b):
	return a.get_stat("cost", a.base_cost) < b.get_stat("cost", b.base_cost)
