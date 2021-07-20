extends Control
class_name MenuNode

onready var menu = $".."

export(NodePath) var right_node = null
export(NodePath) var down_node = null
export(NodePath) var left_node = null
export(NodePath) var up_node = null


func on_pressed():
	pass


func on_hovered():
	pass


func get_next_node(direction):
	if direction == Vector2.RIGHT:
		if right_node:
			return get_node(right_node)
	elif direction == Vector2.DOWN:
		if down_node:
			return get_node(down_node)
	elif direction == Vector2.LEFT:
		if left_node:
			return get_node(left_node)
	elif direction == Vector2.UP:
		if up_node:
			return get_node(up_node)
				
	return null


func _on_Node_mouse_entered():
	menu.selected_node = self


func _on_Node_mouse_exited():
	if menu.selected_node == self:
		menu.selected_node = null
