extends Node


const RAPID_FIRE_WAIT = { # How long to wait before rapid fire is active
	"keyboard_movement" : 0.2,
	"camera_movement" : 0.3,
	"round_manipulation" : 0.3,
	"restart" : 125,
	"follower_selection" : 0.3
}

const RAPID_FIRE_INTERVAL = { # How long to wait before allowing the action to fire again
	"keyboard_movement" : 0.01,
	"camera_movement" : 0.01,
	"round_manipulation" : 0.04,
	"restart" : 0.2,
	"follower_selection" : 0.05
}

const RAPID_FIRE_HOLD = { # How long to wait until rapid fire must be reinitialized
	"keyboard_movement" : 0.1,
	"camera_movement" : 0.1,
	"round_manipulation" : 0.1,
	"restart" : 0.1,
	"follower_selection" : 0.1
}

const RAPID_FIRE_GROUP = {
	"keyboard_right" : "keyboard_movement",
	"keyboard_down" : "keyboard_movement",
	"keyboard_left" : "keyboard_movement",
	"keyboard_up" : "keyboard_movement",
	"keyboard_camera_right" : "camera_movement",
	"keyboard_camera_down" : "camera_movement",
	"keyboard_camera_left" : "camera_movement",
	"keyboard_camera_up" : "camera_movement",
	"keyboard_advance" : "round_manipulation",
	"keyboard_undo" : "round_manipulation",
	"keyboard_redo" : "round_manipulation",
	"mouse_restart" : "restart",
	"keyboard_restart" : "restart",
	"keyboard_previous" : "follower_selection",
	"keyboard_next" : "follower_selection"
}


var time_held = RAPID_FIRE_GROUP.duplicate()
var time_since_fired
var time_since_released = RAPID_FIRE_HOLD.duplicate()


func _ready():
	for key in time_held.keys():
		time_held[key] = 0
	time_since_fired = time_held.duplicate()


func _process(delta):
	for action in time_held:
		var group = RAPID_FIRE_GROUP[action]
		if Input.is_action_pressed(action):
			if time_since_released[group] <= RAPID_FIRE_HOLD[group]:
				time_held[action] = RAPID_FIRE_WAIT[group]
			if time_held[action] > RAPID_FIRE_WAIT[group]:
				time_since_released[group] = RAPID_FIRE_HOLD[group]
			time_held[action] += delta
			time_since_fired[action] += delta
		elif Input.is_action_just_released(action):
			if (time_held[action] > RAPID_FIRE_WAIT[group]):
				time_since_released[group] = 0 
			time_held[action] = 0
		else:
			time_since_released[group] += delta
	
	for action in fired:
		time_since_fired[action] = 0
	fired.clear()

var fired = []

func is_action_pressed_with_rapid_fire(action):
	var pressed = Input.is_action_just_pressed(action) \
		or (time_held[action] > RAPID_FIRE_WAIT[RAPID_FIRE_GROUP[action]] and \
			time_since_fired[action] >= RAPID_FIRE_INTERVAL[RAPID_FIRE_GROUP[action]])
	
	if pressed:
		fired.append(action)
		return true
		
	return false


func get_keyboard_input(simple = false):
	if simple:
		return Vector2((1 if Input.is_action_pressed("keyboard_right") else 0) \
		- (1 if Input.is_action_pressed("keyboard_left") else 0), \
		(1 if Input.is_action_pressed("keyboard_down") else 0) \
		- (1 if Input.is_action_pressed("keyboard_up") else 0))
		
	var movement = Vector2(0, 0)
	movement.x += 1 if is_action_pressed_with_rapid_fire("keyboard_right") else 0
	movement.x += -1 if is_action_pressed_with_rapid_fire("keyboard_left") else 0
	movement.y += -1 if is_action_pressed_with_rapid_fire("keyboard_up") else 0
	movement.y += 1 if is_action_pressed_with_rapid_fire("keyboard_down") else 0
	return movement


func get_camera_input(simple = false):
	if simple:
		return Vector2((1 if Input.is_action_pressed("keyboard_camera_right") else 0) \
		- (1 if Input.is_action_pressed("keyboard_camera_left") else 0), \
		(1 if Input.is_action_pressed("keyboard_camera_down") else 0) \
		- (1 if Input.is_action_pressed("keyboard_camera_up") else 0))
		
	var movement = Vector2(0, 0)
	movement.x += 1 if is_action_pressed_with_rapid_fire("keyboard_camera_right") else 0
	movement.x += -1 if is_action_pressed_with_rapid_fire("keyboard_camera_left") else 0
	movement.y += -1 if is_action_pressed_with_rapid_fire("keyboard_camera_up") else 0
	movement.y += 1 if is_action_pressed_with_rapid_fire("keyboard_camera_down") else 0
	return movement
