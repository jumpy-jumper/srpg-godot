class_name Cursor
extends Node2D
# The player's main tool for interacting with the stage.
# When operatable, the player can move the cursor around the stage.
# The cursor holds a hovered unit and a hovered terrain, which correspond to
# its position on the stage grid.

signal position_updated(pos)
signal position_clicked(pos)

var operatable: bool = true

onready var _animated_sprite : AnimatedSprite = $AnimatedSprite


func _process(_delta) -> void:
	if not operatable:
		visible = false
		return

	visible = true

	position = Stage.POSITION_IN_GRID(get_global_mouse_position())
	emit_signal("position_updated", position)

	if Input.is_action_just_pressed("ui_accept"):
		_animated_sprite.play("select")
		emit_signal("position_clicked", position)
