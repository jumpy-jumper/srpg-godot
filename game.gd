extends Node2D


export var mouse_enabled = true
export var undoable_restart = true
export var redo_enabled = true
export var decouple_mouse_and_keyboard = false
export var hide_mouse_after_seconds = 2
export var confirm_facing_on_release = true
export var automatically_move_enemies = true
export var enemy_movement_wait = 0.2
export var zoom_sensitivity = 1.15
export var mouse_drag_camera_sensitivity = 3
export var move_camera_with_cancel = true
export var unit_ui_with_cancel_leeway = 100
export var inverted_camera_keyboard = false
export var inverted_camera_mouse = false

var mouse_idle = 0
var prev_pos = Vector2.ZERO


export var autoload = false
var level_to_load = preload("res://Levels/l_east02.tscn")


func _ready():
	randomize()
	if OS.is_debug_build():
		OS.set_window_size(Vector2(1920, 1080))  
		var screen_size = OS.get_screen_size(0)
		var window_size = OS.get_window_size()
		OS.set_window_position(screen_size*0.5 - window_size*0.5)
		

func _process(_delta):
	mouse_idle = 0 if get_viewport().get_mouse_position() != prev_pos else mouse_idle + _delta
	if InputWatcher.get_keyboard_input().length_squared() > 0:
		mouse_idle = hide_mouse_after_seconds
	prev_pos = get_viewport().get_mouse_position()
	
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen

	elif Input.is_action_just_pressed("restart_game"):
		get_tree().change_scene("res://title.tscn")
	
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE \
		if mouse_idle < Game.hide_mouse_after_seconds \
		else Input.MOUSE_MODE_HIDDEN)
