extends Node2D


onready var stage = $"../.."

func _process(_delta):
	var unit = stage.summoners_cache[0]
	$AnimatedSprite.frames = unit.get_node("Sprite").frames
	$Faith.text = str(unit.faith)
