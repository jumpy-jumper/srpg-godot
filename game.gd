extends Node2D


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
var level_to_load = preload("res://Levels/east02.tscn")


export var settings = {
	"resolution" : Vector2(1280, 720),
	"fullscreen" : false,
	"cursor_mouse_controls" : true,
	"camera_mouse_controls" : true,
	"inverted_keyboard_camera" : false,
	"inverted_mouse_camera" : false,
	"undoable_restart" : true,
	"nils_voice_lines" : false,
}

func _ready():
	randomize()
	load_settings()
	apply_settings()

func load_settings():
	var settings_file = File.new()
	if settings_file.file_exists("user://dit_config.json"):
		settings_file.open("user://dit_config.json", File.READ)
		var new_settings = parse_json(settings_file.get_as_text())
		if new_settings:
			for key in settings.keys():
				if new_settings.has(key):
					var regex = RegEx.new()
					regex.compile("([0-9]+, [0-9]+)") # check if it's Vector2
					if new_settings[key] is String and regex.search(new_settings[key]):
						regex.compile("[0-9]+")
						var result = regex.search_all(new_settings[key])
						settings[key] = Vector2(int(result[0].get_string()), int(result[1].get_string()))
					else:
						settings[key] = new_settings[key]
		settings_file.close()

func apply_settings():
	OS.set_window_size(settings["resolution"])
	var screen_size = OS.get_screen_size(0)
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	OS.window_fullscreen = settings["fullscreen"]
	
	var settings_file = File.new()
	settings_file.open("user://dit_config.json", File.WRITE)
	settings_file.store_line(to_json(settings))
	settings_file.close()	

func _process(_delta):
	mouse_idle = 0 if get_viewport().get_mouse_position() != prev_pos else mouse_idle + _delta
	if InputWatcher.get_keyboard_input().length_squared() > 0:
		mouse_idle = hide_mouse_after_seconds
	prev_pos = get_viewport().get_mouse_position()
	
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen

	elif Input.is_action_just_pressed("restart_game"):
		get_tree().change_scene("res://Title/title.tscn")
	
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE \
		if mouse_idle < Game.hide_mouse_after_seconds \
		else Input.MOUSE_MODE_HIDDEN)
