extends Control


onready var stage = $"../.."


func _process(_delta):
	$RichTextLabel.bbcode_text = "[center]"
	$RichTextLabel.bbcode_text += str(stage.cur_tick) + " // "
	var winds = ["East", "South", "West", "North"]
	$RichTextLabel.bbcode_text += winds[stage.cur_tick % 16 / 4] + "-"
	$RichTextLabel.bbcode_text += str((stage.cur_tick - 1) % 16 % 4 + 1) + "\n"
	for i in range (4):
		if i == (stage.cur_tick - 1) % 4:
			$RichTextLabel.bbcode_text += "[color=#03FFEE]"
		$RichTextLabel.bbcode_text += winds[i][0] + " "
		if i == (stage.cur_tick - 1) % 4:
			$RichTextLabel.bbcode_text += "[/color]"
	$RichTextLabel.bbcode_text += "[/center]"
			