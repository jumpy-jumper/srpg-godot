extends Node


func _process(_delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
	elif Input.is_action_just_pressed("debug_reload_scene"):
		get_tree().reload_current_scene()
