extends Node


const RAPID_FIRE_WAIT = { # How long to wait before rapid fire is active
	"ui_right" : 0.2,
	"ui_down" : 0.2,
	"ui_left" : 0.2,
	"ui_up" : 0.2,
	"camera_right" : 0.3,
	"camera_down" : 0.3,
	"camera_left" : 0.3,
	"camera_up" : 0.3,
	"advance_round" : 0.3,
	"undo" : 0.3,
	"redo" : 0.3,
	"restart" : 125,
	"previous_follower" : 0.3,
	"next_follower" : 0.3
}

const RAPID_FIRE_INTERVAL = { # How long to wait before allowing the action to fire again
	"ui_right" : 0.02,
	"ui_down" : 0.02,
	"ui_left" : 0.02,
	"ui_up" : 0.02,
	"camera_right" : 0,
	"camera_down" : 0,
	"camera_left" : 0,
	"camera_up" : 0,
	"advance_round" : 0.01,
	"undo" : 0.01,
	"redo" : 0.01,
	"restart" : 0.2,
	"previous_follower" : 0.05,
	"next_follower" : 0.05
}

const RAPID_FIRE_HOLD = { # How long to wait until rapid fire must be reinitialized
	"ui_movement" : 0.1,
	"camera_movement" : 0.1,
	"round_manipulation" : 0.1,
	"restart" : 0.1,
	"follower_selection" : 0.1
}

const HOLD_GROUP = {
	"ui_right" : "ui_movement",
	"ui_down" : "ui_movement",
	"ui_left" : "ui_movement",
	"ui_up" : "ui_movement",
	"camera_right" : "camera_movement",
	"camera_down" : "camera_movement",
	"camera_left" : "camera_movement",
	"camera_up" : "camera_movement",
	"advance_round" : "round_manipulation",
	"undo" : "round_manipulation",
	"redo" : "round_manipulation",
	"restart" : "restart",
	"previous_follower" : "follower_selection",
	"next_follower" : "follower_selection"
}

var time_held = RAPID_FIRE_INTERVAL.duplicate()
var time_since_fired = RAPID_FIRE_INTERVAL.duplicate()
var time_since_released = RAPID_FIRE_HOLD.duplicate()


func _process(delta):
	for action in time_held:
		if Input.is_action_pressed(action):
			if time_since_released[HOLD_GROUP[action]] <= RAPID_FIRE_HOLD[HOLD_GROUP[action]]:
				time_held[action] = RAPID_FIRE_WAIT[action]
			time_since_released[HOLD_GROUP[action]] = RAPID_FIRE_HOLD[HOLD_GROUP[action]]
			time_held[action] += delta
			time_since_fired[action] += delta
		elif Input.is_action_just_released(action):
			if (time_held[action] > RAPID_FIRE_WAIT[action]):
				time_since_released[HOLD_GROUP[action]] = 0 
			time_held[action] = 0
		else:
			time_since_released[HOLD_GROUP[action]] += delta


func is_action_pressed_with_rapid_fire(action):
	var pressed = Input.is_action_just_pressed(action) \
		or (time_held[action] > RAPID_FIRE_WAIT[action] and \
			time_since_fired[action] >= RAPID_FIRE_INTERVAL[action])
	
	if pressed:
		time_since_fired[action] = 0
		return true
		
	return false


func get_keyboard_input(simple = false):
	if simple:
		return Vector2((1 if Input.is_action_pressed("ui_right") else 0) \
		- (1 if Input.is_action_pressed("ui_left") else 0), \
		(1 if Input.is_action_pressed("ui_down") else 0) \
		- (1 if Input.is_action_pressed("ui_up") else 0))
		
	var movement = Vector2(0, 0)
	movement.x += 1 if is_action_pressed_with_rapid_fire("ui_right") else 0
	movement.x += -1 if is_action_pressed_with_rapid_fire("ui_left") else 0
	movement.y += -1 if is_action_pressed_with_rapid_fire("ui_up") else 0
	movement.y += 1 if is_action_pressed_with_rapid_fire("ui_down") else 0
	return movement


func get_camera_input(simple = false):
	if simple:
		return Vector2((1 if Input.is_action_pressed("camera_right") else 0) \
		- (1 if Input.is_action_pressed("camera_left") else 0), \
		(1 if Input.is_action_pressed("camera_down") else 0) \
		- (1 if Input.is_action_pressed("camera_up") else 0))
		
	var movement = Vector2(0, 0)
	movement.x += 1 if is_action_pressed_with_rapid_fire("camera_right") else 0
	movement.x += -1 if is_action_pressed_with_rapid_fire("camera_left") else 0
	movement.y += -1 if is_action_pressed_with_rapid_fire("camera_up") else 0
	movement.y += 1 if is_action_pressed_with_rapid_fire("camera_down") else 0
	return movement
