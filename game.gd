extends Node


export var mouse_enabled = true
export var undoable_restart = true
export var redo_enabled = false
export var decouple_mouse_and_keyboard = true
export var hide_mouse_after_seconds = 2
export var confirm_facing_on_release = true


func _process(_delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
