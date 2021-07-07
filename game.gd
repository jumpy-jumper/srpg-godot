extends Node2D


export var mouse_enabled = true
export var undoable_restart = true
export var redo_enabled = true
export var decouple_mouse_and_keyboard = true
export var hide_mouse_after_seconds = 2
export var confirm_facing_on_release = true


var mouse_idle = 0
var prev_pos = Vector2.ZERO

func _process(_delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
	mouse_idle = 0 if get_global_mouse_position() != prev_pos else mouse_idle + _delta
	prev_pos = get_global_mouse_position()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE \
		if mouse_idle < Game.hide_mouse_after_seconds \
		else Input.MOUSE_MODE_HIDDEN)
