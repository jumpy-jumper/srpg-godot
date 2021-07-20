extends Control


onready var stage = $"../.."


func _process(_delta):
	visible = true
	var unit = stage.get_selected_summoner()
	if (unit.get_node("View/Sprite").frames != $AnimatedSprite.frames):
		$AnimatedSprite.frames = unit.get_node("View/Sprite").frames
	$Faith.text = str(unit.faith)
	if not stage.is_won():
		$Faith.text += " / " + str(stage.level.checkpoints[stage.cur_level_index])
