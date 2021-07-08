extends Node2D


var path_node = preload("res://Unit/Path/path_node.tscn")

func update_path(path):
	var necessary_children = max(0, len(path) - get_child_count() - 1)
	
	for i in range(necessary_children):
		var node = path_node.instance()
		add_child(node)
	
	var children = get_children()
	for i in range(1, len(path)):
		if i >= len(path):
			children[i-1].visible = false
		else:
			children[i-1].visible = true
			children[i-1].global_position = Vector2(32, 32) + path[i]
			var from_previous_node = (path[i] - path[i-1])
			children[i-1].rotation = atan2(from_previous_node.y, from_previous_node.x)
