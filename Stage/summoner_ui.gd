extends Control


onready var stage = $"../../.."

export var summoner_index = 0

func _process(_delta):
	visible = true
	if summoner_index < len(stage.summoners_cache):
		var unit = stage.summoners_cache[summoner_index]
		if unit.alive:
			visible = true
			if (unit.get_node("Sprite").frames != $AnimatedSprite.frames):
				$AnimatedSprite.frames = unit.get_node("Sprite").frames
			$Faith.text = str(unit.faith)
		else:
			visible = false
	else:
		visible = false
