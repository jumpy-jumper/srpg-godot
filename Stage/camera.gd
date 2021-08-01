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

var operatable = false

var base_mouse_position = Vector2.ZERO
onready var base_camera_position = position
onready var tween = $Tween


func _process(_delta):
	if stage.can_move_camera():
		var movement = InputWatcher.get_camera_input()
		movement = Vector2(round(movement.x), round(movement.y)).rotated(PI if Game.settings["inverted_keyboard_camera"] else 0)
		if Game.inverted_camera_keyboard:
			movement = -movement
		
		var newpos = position + movement * stage.get_cell_size()
		
		if movement.length_squared() > 0:
			position = newpos

		var new_zoom
		if Input.is_action_just_pressed("zoom"):
			if zoom == zoom_out * stage.level.default_camera_zoom:
				new_zoom = zoom_in * stage.level.default_camera_zoom	
				$Tween.interpolate_property(self, "zoom", 
				zoom, new_zoom, ZOOM_SPEED,
				Tween.TRANS_LINEAR, Tween.EASE_OUT)
				$Tween.start()
			else:
				new_zoom = zoom_out * stage.level.default_camera_zoom
				$Tween.interpolate_property(self, "zoom", 
				zoom, new_zoom, ZOOM_SPEED,
				Tween.TRANS_LINEAR, Tween.EASE_OUT)
				$Tween.start()
	
	if Game.settings["camera_mouse_controls"]:
		if Input.is_action_just_pressed("mouse_cancel") \
			and stage.can_move_camera_with_cancel():
				#position = get_global_mouse_position()
				base_mouse_position = get_viewport().get_mouse_position()
				base_camera_position = position
				operatable = true
			
		if operatable \
			and (Input.is_action_pressed("mouse_cancel") \
			and stage.can_move_camera_with_cancel()):
				var offset = (base_mouse_position - get_viewport().get_mouse_position()) * zoom
				if Game.settings["inverted_mouse_camera"]:
					offset = -offset
				position = base_camera_position + offset
		
		if Input.is_action_just_released("mouse_cancel") and operatable:
				operatable = false
	else:
		operatable = false
	
	if Input.is_action_just_pressed("debug_get_camera_position_and_zoom"):
		print(position + offset)
		print(zoom)



const ZOOM_SPEED = 0.125
const ZOOM_POSITION_CORRECTION = 0.15
func _input(event):
	if operatable:
		if event.is_action_pressed("zoom_in"):
			tween.interpolate_property(self, "zoom",
			zoom, zoom * Game.zoom_sensitivity, 0.0625,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
			
			tween.interpolate_property(self, "offset",
			offset, offset - (get_global_mouse_position() - (position + offset)) * ZOOM_POSITION_CORRECTION, 0.0625,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
			
			tween.start()
		elif event.is_action_pressed("zoom_out"):
			tween.interpolate_property(self, "zoom",
			zoom, zoom / Game.zoom_sensitivity, 0.0625,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
			
			tween.interpolate_property(self, "offset",
			offset, offset + (get_global_mouse_position() - (position + offset)) * ZOOM_POSITION_CORRECTION, 0.0625,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
			
			tween.start()
		elif event.is_action_pressed("zoom_reset"):
			tween.interpolate_property(self, "zoom",
			zoom, stage.level.default_camera_zoom, 0.25,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
			tween.start()
			
			tween.interpolate_property(self, "position",
			position, stage.level.default_camera_position - offset, 0.25,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
			tween.start()
