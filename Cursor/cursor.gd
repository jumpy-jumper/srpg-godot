class_name Cursor
extends Node2D
# The player's main tool for interacting with the stage.
# When operatable, the player can move the cursor around the stage.
# The cursor snaps to the stage's grid.
# The cursor emits signals when it updates position or clicks a position.


signal moved(pos)
signal hovered(pos)
signal confirm_issued(pos)
signal cancel_issued(pos)


const DEFAULT_CELL_SIZE = 64


var stage = null
var old_mouse_pos = position
var old_keyboard_pos = position


var mouse_inactive = 0


enum ControlState { FREE, LOCKED, HIDDEN }
var control_state = ControlState.FREE

enum ControlType { DIGITAL, ANALOG }
var control_type = ControlType.DIGITAL

var analog_pos = position
const ANALOG_SPEED = 400

func _process(_delta):
	if control_state == ControlState.HIDDEN:
		visible = false
		return

	visible = true
	if stage:
		$AnimatedSprite.centered = false
	else:
		$AnimatedSprite.centered = true

	if control_state == ControlState.FREE:
		var previous = position

		var movement = InputWatcher.get_keyboard_input()

		if get_viewport().get_mouse_position() == old_mouse_pos:
			mouse_inactive += _delta
			if Game.decouple_mouse_and_keyboard and movement.length() > 0:
				position = old_keyboard_pos
			if stage:
				position += stage.get_clamped_position(stage.get_cell_size() * movement)
		elif Game.mouse_enabled:
			mouse_inactive = 0
			if stage:
				var newpos = stage.get_clamped_position(get_global_mouse_position())
				if stage.get_terrain_at(newpos) != null:
					position = stage.get_clamped_position(get_global_mouse_position())
			else:
				position = get_global_mouse_position()
			$"AnimatedSprite/Parent Follower".snap()
		else:
			position += DEFAULT_CELL_SIZE * movement

		if stage:
			stage.get_terrain_at(position)
			if stage.get_terrain_at(position) == null:
				if stage.get_terrain_at(Vector2(position.x, previous.y)) != null:
					position = Vector2(position.x, previous.y)
				elif stage.get_terrain_at(Vector2(previous.x, position.y)) != null:
					position = Vector2(previous.x, position.y)
				else:
					position = previous

		if movement.length() > 0:
			old_keyboard_pos = position

		if position != previous:
			emit_signal("moved", position)

		old_mouse_pos = get_viewport().get_mouse_position()
			

	if Input.is_action_just_pressed("confirm") and not Input.is_action_pressed("control"):
		$AnimatedSprite.play("default")
		$AnimatedSprite.play("select")
		emit_signal("confirm_issued", position)

	if Input.is_action_just_pressed("cancel") and not Input.is_action_pressed("control"):
		emit_signal("cancel_issued", position)
		
	emit_signal("hovered", position)


func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.play("default")
