extends Node2D


onready var stage = $".."
onready var camera = $"../Camera2D"
onready var tween = camera.get_node("Tween")


var operatable = false

var base_mouse_position = Vector2.ZERO
onready var base_camera_position = camera.position

func _process(_delta):
	if Input.is_action_just_pressed("cancel") and stage.can_move_camera_with_cancel() \
		or Input.is_action_just_pressed("drag_camera"):
			position = get_global_mouse_position()
			base_mouse_position = get_viewport().get_mouse_position()
			base_camera_position = camera.position
			operatable = true
		
	if Input.is_action_pressed("cancel") \
		and stage.can_move_camera_with_cancel() \
		or Input.is_action_pressed("drag_camera"):
			camera.position = base_camera_position + (base_mouse_position - get_viewport().get_mouse_position()) * camera.zoom
	
	if Input.is_action_just_released("cancel") \
		and stage.can_move_camera_with_cancel() \
		or Input.is_action_just_released("drag_camera") \
		and operatable:
			operatable = false


func _input(event):
	if operatable:
		if event.is_action_pressed("zoom_in"):
			camera.zoom *= Game.zoom_sensitivity
		elif event.is_action_pressed("zoom_out"):
			camera.zoom /= Game.zoom_sensitivity
		elif event.is_action_pressed("zoom_reset"):
			tween.interpolate_property(camera, "zoom",
			camera.zoom, Vector2(1, 1), 0.25,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
			tween.start()
