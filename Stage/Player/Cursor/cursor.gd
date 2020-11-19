class_name Cursor
extends Node2D
# The player's main tool for interacting with the stage.
# When operatable, the player can move the cursor around the stage.
# The cursor holds a hovered unit and a hovered terrain, which correspond to
# its position on the stage grid.

var operatable: bool = true
var hovered_unit: Unit = null
var hovered_terrain: Terrain = null

onready var _stage: Stage = $"../.."
onready var _animated_sprite : AnimatedSprite = $AnimatedSprite


func _process(_delta) -> void:
	if not operatable:
		visible = false
		return

	visible = true

	# Update position
	position = get_global_mouse_position()
	position.x = floor(position.x / Stage.GRID_SIZE) * Stage.GRID_SIZE
	position.y = floor(position.y / Stage.GRID_SIZE) * Stage.GRID_SIZE

	# Update hovered unit
	var previous = hovered_unit
	hovered_unit = _stage.get_unit_at(position)
	if hovered_unit != previous:
		if previous:
			previous.on_unhovered()
		if hovered_unit:
			hovered_unit.on_hovered()

	hovered_terrain = _stage.get_terrain_at(position)

	# Send click events to selected unit
	if Input.is_action_just_pressed("ui_accept"):
		_animated_sprite.play("select")
		_stage.cur_unit.on_click_while_selected(position)
