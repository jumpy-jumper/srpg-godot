extends Camera2D


onready var stage = $".."
onready var cursor = stage.get_node("Cursor")


export var left_cutoff = 4
export var right_cutoff = 6
export var top_cutoff = 4
export var bottom_cutoff = 4

export var speed = 0.5

var zoom_out = 1.5
var zoom_in = 1
const ZOOM_SPEED = 0.125


func _process(_delta):
	if stage.can_move_camera():
		var movement = Vector2(0, 0)
		movement.x += 1 if get_movement("camera_right") else 0
		movement.x += -1 if get_movement("camera_left") else 0
		movement.y += -1 if get_movement("camera_up") else 0
		movement.y += 1 if get_movement("camera_down") else 0
		
		movement = Vector2(round(movement.x), round(movement.y))
		
		var newpos = position + movement * stage.get_cell_size()
		
		if movement.length_squared() > 0:
			update_pos(newpos)

		var new_zoom
		if Input.is_action_just_pressed("zoom"):
			if zoom.x == zoom_out:
				new_zoom = Vector2(zoom_in, zoom_in)		
				$Tween.interpolate_property(self, "zoom", 
				zoom, new_zoom, ZOOM_SPEED,
				Tween.TRANS_LINEAR, Tween.EASE_OUT)
				$Tween.start()
			else:
				new_zoom = Vector2(zoom_out, zoom_out)		
				$Tween.interpolate_property(self, "zoom", 
				zoom, new_zoom, ZOOM_SPEED,
				Tween.TRANS_LINEAR, Tween.EASE_OUT)
				$Tween.start()

	

func update_pos(pos):
	$Tween.stop_all()
	$Tween.interpolate_property(self, "position", 
	position, pos, speed,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()


export var rapid_fire_wait = 10
export var rapid_fire_interval = 1
export var rapid_fire_hold = 30


var timers = {
	"camera_right" : 0,
	"camera_left" : 0,
	"camera_down" : 0,
	"camera_up" : 0,
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
