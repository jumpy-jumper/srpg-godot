extends Control
class_name NavigatableMenu


export var operatable = true
enum Navigation { EXPLICIT, IMPLICIT }
export(Navigation) var navigation = Navigation.IMPLICIT

export(NodePath) var selected_node = null
var mouse_focus = null
export(NodePath) var initial = null


onready var tween = $Tween
onready var cursor = $Cursor

export var cursor_padding = Vector2(8, 8)

func _ready():
	if selected_node:
		selected_node = get_node(selected_node)


func _process(_delta):
	if mouse_focus and mouse_focus != selected_node:
		$MouseFocus.visible = true
		$MouseFocus.rect_position = mouse_focus.rect_position - cursor_padding / 2
		$MouseFocus.rect_size = mouse_focus.rect_size + cursor_padding
	else:
		$MouseFocus.visible = false	
	
	var movement = InputWatcher.get_keyboard_input()
	if operatable:
		if selected_node:
			if navigation == Navigation.EXPLICIT:
				if movement.length_squared() > 0:
					var next_node = selected_node.get_next_node(movement)
					if next_node:
						selected_node = next_node
			elif navigation == Navigation.IMPLICIT:
				if movement.length_squared() > 0:
					selected_node = get_next_node(movement)
			
			if Input.is_action_just_released("confirm"):
				if mouse_focus != null:
					mouse_focus.on_pressed()
					selected_node = mouse_focus
				else:
					selected_node.on_pressed()
			
			cursor.visible = true
			cursor.rect_position = selected_node.rect_position - cursor_padding / 2
			cursor.rect_size = selected_node.rect_size + cursor_padding
		else:
			if movement.length_squared() > 0 and initial:
				selected_node = get_node(initial)
			cursor.visible = false


# Implicit navigation - returns the next node in the ordering implied by pressed direction
func get_next_node(direction):
	var nodes = get_children()
	for child in nodes + []:
		if not child is MenuNode:
			nodes.erase(child)
	
	var closest = selected_node
	var closest_distance = 12987361297836
	var farthest = selected_node
	var farthest_distance = 12987361297836
	
	for node in nodes:
		var distance = (node.rect_position * direction - selected_node.rect_position * direction)
		distance = distance.x + distance.y
		if distance > 0 and distance < closest_distance:
			closest_distance = distance
			closest = node
		if distance < 0 and distance < farthest_distance:
			farthest_distance = distance
			farthest = node
	
	return closest if closest != selected_node else farthest
