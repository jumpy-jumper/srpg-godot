class_name Cursor
extends Node2D



var selected = null
var hovered = null

onready var _stage = get_tree().root.get_node("Stage")	


func _process(_delta):
	if not selected:
		get_parent().get_node("Player HUD").cur_unit = null
		visible = false
		return
		
	visible = true
	
	# Update position
	position = get_global_mouse_position()
	position.x = floor(position.x / Stage.GRID_SIZE)
	position.y = floor(position.y / Stage.GRID_SIZE)
	position *= Stage.GRID_SIZE
	
	# Update hovered unit
	var previous = hovered
	hovered = _stage.get_unit_at(position)
	if hovered != previous:
		if previous:
			previous.on_unhovered()
		if hovered:
			hovered.on_hovered()
	
	# Update UI
	get_parent().get_node("Player HUD").cur_unit = hovered
		
	# Send click events to selected unit
	if Input.is_action_just_pressed("ui_accept"):
		$AnimatedSprite.play("select")
		selected.on_click_while_selected(position)
