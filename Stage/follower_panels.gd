extends Control


onready var stage = $"../.."


var follower_panel = preload("res://Stage/UI/follower_panel.tscn")


func update_ui():
	for panel in get_children():
		panel.queue_free()	

	var followers = stage.summoners_cache[0].followers
	for i in range(len(followers)):
		var unit = stage.summoners_cache[0].followers[i]
		var panel = follower_panel.instance()
		add_child(panel)
		panel.update_unit(unit.instance())
		panel.position = Vector2(128 * i , 0)
