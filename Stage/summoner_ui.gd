extends Node2D


onready var stage = $"../.."


func _process(_delta):
	visible = true
	var unit = stage.get_selected_summoner()
	if (unit.get_node("Sprite").frames != $AnimatedSprite.frames):
		$AnimatedSprite.frames = unit.get_node("Sprite").frames
	$Faith.text = str(unit.faith)
