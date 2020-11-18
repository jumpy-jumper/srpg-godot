class_name Cursor

extends Node2D

# There must be a stage
var stage
func _ready():
	stage = get_tree().root.get_node("Stage")

var selected = null
var hovered = null

func _process(_delta):
	if not selected:
		get_parent().get_node("Player HUD").cur_unit = null
		visible = false
		return
		
	visible = true
	
	# Update position
	position = get_global_mouse_position()
	position.x = floor(position.x / Stage.grid_size)
	position.y = floor(position.y / Stage.grid_size)
	position *= Stage.grid_size
	
	# Update hovered unit
	var previous = hovered
	hovered = stage.get_unit_at(position)
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
