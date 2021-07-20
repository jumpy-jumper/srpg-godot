extends Node


export var default_camera_position = Vector2(640, 368)
export var default_camera_zoom = Vector2.ONE

export var checkpoints = []

func _ready():
	# If the current scene is ran, load the stage scene with this level
	if get_tree().get_current_scene() == self:
		Game.level_to_load = load(filename)
		get_tree().change_scene("res://Stage/stage.tscn")
