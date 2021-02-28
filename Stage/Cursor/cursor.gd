class_name Cursor
extends Node2D
# The player's main tool for interacting with the stage.
# When operatable, the player can move the cursor around the stage.
# The cursor snaps to the stage's grid.
# The cursor emits signals when it updates position or clicks a position.


signal position_changed(pos)
signal position_clicked(pos)

export var operatable = true
var stage = null

func _process(_delta):
	if not operatable:
		visible = false
		return

	visible = true

	var previous = position
	if stage:
		position = stage.get_position_in_grid(get_global_mouse_position())
		$AnimatedSprite.centered = false
	else:
		position = get_global_mouse_position()
		$AnimatedSprite.centered = true

	if position != previous:
		emit_signal("position_changed", position)

	if Input.is_action_just_pressed("ui_accept"):
		$AnimatedSprite.play("default")
		$AnimatedSprite.play("select")
		emit_signal("position_clicked", position)
