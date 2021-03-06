class_name Cursor
extends Node2D
# The player's main tool for interacting with the stage.
# When operatable, the player can move the cursor around the stage.
# The cursor snaps to the stage's grid.
# The cursor emits signals when it updates position or clicks a position.


signal moved(pos)
signal confirm_issued(pos)
signal cancel_issued(pos)
signal end_turn_issued()


const DEFAULT_CELL_SIZE = 64

export var operatable = true
export var enable_mouse_input = true
export var decouple_mouse_and_keyboard = false

var stage = null
var old_mouse_pos = position
var old_keyboard_pos = position


func _process(_delta):
	if not operatable:
		visible = false
		return

	visible = true
	if stage:
		$AnimatedSprite.centered = false
	else:
		$AnimatedSprite.centered = true

	var previous = position
	var mouse_pos = get_global_mouse_position()

	var movement = Vector2(0, 0)
	movement.x += 1 if get_movement("ui_right") else 0
	movement.x += -1 if get_movement("ui_left") else 0
	movement.y += -1 if get_movement("ui_up") else 0
	movement.y += 1 if get_movement("ui_down") else 0

	if mouse_pos == old_mouse_pos:
		if decouple_mouse_and_keyboard and movement.length() > 0:
			position = old_keyboard_pos

		if stage:
			position += stage.get_node("Terrain").cell_size * movement
			if stage.get_node("Terrain").get_cellv(stage.get_tilemap_position(position)) == -1:
				if stage.get_node("Terrain").get_cellv(stage.get_tilemap_position(Vector2(position.x, previous.y))) > -1:
					position = Vector2(position.x, previous.y)
				elif stage.get_node("Terrain").get_cellv(stage.get_tilemap_position(Vector2(previous.x, position.y))) > -1:
					position = Vector2(previous.x, position.y)
				else:
					position = previous
		else:
			position += DEFAULT_CELL_SIZE * movement

		if movement.length() > 0:
			old_keyboard_pos = position
	elif enable_mouse_input:
		if stage:
			position = stage.get_position_in_grid(mouse_pos)
		else:
			position = mouse_pos

	if Input.is_action_just_pressed("ui_accept"):
		$AnimatedSprite.play("default")
		$AnimatedSprite.play("select")
		emit_signal("confirm_issued", position)

	if Input.is_action_just_pressed("ui_cancel"):
		emit_signal("cancel_issued", position)

	if position != previous:
		emit_signal("moved", position)

	old_mouse_pos = get_global_mouse_position()


export var rapid_fire_wait = 20
export var rapid_fire_interval = 3

var timers = {
	"ui_right" : 0,
	"ui_left" : 0,
	"ui_down" : 0,
	"ui_up" : 0,
}

func get_movement(dir):
	if Input.is_action_just_released(dir) or not Input.is_action_pressed(dir):
		timers[dir] = 0
	timers[dir] += 1

	var rapid_fire_condition = false

	for t in timers:
		if timers[t] > rapid_fire_wait:
			rapid_fire_condition = true

	if rapid_fire_condition:
		return timers[dir] % rapid_fire_interval == 0 and Input.is_action_pressed(dir)
	else:
		return Input.is_action_just_pressed(dir)

