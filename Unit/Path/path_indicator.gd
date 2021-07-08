extends Node2D


var path_node = preload("res://Unit/Path/path_node.tscn")

func update_path(path):
	var necessary_children = max(0, len(path) - get_child_count() - 1)
	
	for i in range(necessary_children):
		var node = path_node.instance()
		add_child(node)
	
	var children = get_children()
	for i in range(0, len(path)):
		if i > len(path):
			children[i-1].visible = false
		else:
			children[i-1].visible = true
			children[i-1].global_position = path[i]
			
			if i > 0:
				children[i-1].get_node("Initial").visible = true
				var dist = (path[i-1] - path[i])
				children[i-1].get_node("Initial").rotation = atan2(dist.y, dist.x)
			else:
				children[i-1].get_node("Initial").visible = false
			
			if i < len(path) - 1:
				children[i-1].get_node("Final").visible = true
				var dist = (path[i+1] - path[i])
				children[i-1].get_node("Final").rotation = atan2(dist.y, dist.x)
			else:
				children[i-1].get_node("Final").visible = false
				
			children[i-1].get_node("Label").text = str(i)
