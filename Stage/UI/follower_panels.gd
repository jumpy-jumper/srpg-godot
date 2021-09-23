extends Control


onready var stage = $"../.."


func _ready():
	for panel in get_children():
		panel.connect("mouse_entered", stage, "_on_UI_mouse_entered")
		panel.connect("mouse_exited", stage, "_on_UI_mouse_exited")


func initialize_ui():
	var i = 0
	
	var groups = stage.follower_groups.values()
	groups.sort_custom(self, "cost_comparison")
	
	for panel in get_children():
		panel.stage = stage
		if i >= len(groups):
			panel.visible = false
		else:
			panel.visible = true
			panel.initialize_panel(groups[i])
		i += 1


func update_ui():	
	for panel in get_children():
		panel.update_panel()


func cost_comparison(a, b):
	return a.values()[0].base_cost < b.values()[0].base_cost
