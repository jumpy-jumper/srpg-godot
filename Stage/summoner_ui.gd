extends Node2D


onready var stage = $"../.."


func _process(_delta):
	visible = true
	var unit = stage.summoners_cache[stage.selected_summoner_index]
	if (unit.get_node("Sprite").frames != $AnimatedSprite.frames):
		$AnimatedSprite.frames = unit.get_node("Sprite").frames
	$Faith.text = str(unit.faith)
