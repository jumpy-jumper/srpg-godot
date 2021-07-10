extends Node2D


export var mouse_enabled = true
export var undoable_restart = true
export var redo_enabled = true
export var decouple_mouse_and_keyboard = false
export var hide_mouse_after_seconds = 2
export var confirm_facing_on_release = true
export var automatically_move_enemies = true
export var enemy_movement_wait = 0.2
export var zoom_sensitivity = 1.3
export var mouse_drag_camera_sensitivity = 3
export var move_camera_with_cancel = true

var mouse_idle = 0
var prev_pos = Vector2.ZERO


export var autoload = false
var level_to_load = preload("res://Levels/l_nils.tscn")


func _ready():
	randomize()


func _process(_delta):
		
	mouse_idle = 0 if get_viewport().get_mouse_position() != prev_pos else mouse_idle + _delta
	if get_keyboard_input().length_squared() > 0:
		mouse_idle = hide_mouse_after_seconds
	prev_pos = get_viewport().get_mouse_position()
	
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen

	elif Input.is_action_just_pressed("restart_game"):
		get_tree().change_scene("res://title.tscn")
	
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE \
		if mouse_idle < Game.hide_mouse_after_seconds \
		else Input.MOUSE_MODE_HIDDEN)


## Input Stuff

export var rapid_fire_wait = 10
export var rapid_fire_interval = 3
export var rapid_fire_hold = 60


var timers = {
	"ui_right" : 0,
	"ui_left" : 0,
	"ui_down" : 0,
	"ui_up" : 0,
}


var rapid_fire_condition_history = []


func get_movement(dir):
		
		
	if Input.is_action_just_released(dir) or not Input.is_action_pressed(dir):
		timers[dir] = 0
	timers[dir] += 1

	var rapid_fire_condition = false

	for t in timers:
		if timers[t] > rapid_fire_wait:
			rapid_fire_condition = true
			
	rapid_fire_condition_history.append(rapid_fire_condition)
	if len(rapid_fire_condition_history) > rapid_fire_hold:
		rapid_fire_condition_history.pop_front()
	
	for b in rapid_fire_condition_history:
		if b:
			rapid_fire_condition = true

	if rapid_fire_condition:
		return timers[dir] % rapid_fire_interval == 0 and Input.is_action_pressed(dir)
	else:
		return Input.is_action_just_pressed(dir)

func get_keyboard_input(simple = false):
	if simple:
		return Vector2((1 if Input.is_action_pressed("ui_right") else 0) \
		- (1 if Input.is_action_pressed("ui_left") else 0), \
		(1 if Input.is_action_pressed("ui_down") else 0) \
		- (1 if Input.is_action_pressed("ui_up") else 0))
		
	var movement = Vector2(0, 0)
	movement.x += 1 if get_movement("ui_right") else 0
	movement.x += -1 if get_movement("ui_left") else 0
	movement.y += -1 if get_movement("ui_up") else 0
	movement.y += 1 if get_movement("ui_down") else 0
	return movement
