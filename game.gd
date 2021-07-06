extends Node


export var mouse_enabled = true
export var undoable_restart = false


func _process(_delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
