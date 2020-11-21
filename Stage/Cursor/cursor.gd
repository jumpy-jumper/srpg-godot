class_name Cursor
extends Node2D
# The player's main tool for interacting with the stage.
# When operatable, the player can move the cursor around the stage.
# The cursor snaps to the stage's grid.
# The cursor emits signals when it updates position or clicks a position.


signal position_changed(pos)
signal position_clicked(pos)

var operatable = true


func _process(_delta):
	if not operatable:
		visible = false
		return

	visible = true

	var previous = position
	position = Stage.GET_POSITION_IN_GRID(get_global_mouse_position())
	if position != previous:
		emit_signal("position_changed", position)
		$AnimatedSprite.play("default")

	if Input.is_action_just_pressed("ui_accept"):
		$AnimatedSprite.play("select")
		emit_signal("position_clicked", position)
