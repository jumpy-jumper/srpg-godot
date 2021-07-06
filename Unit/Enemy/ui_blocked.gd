extends Sprite


onready var unit = $".."


func _process(_delta):
	visible = unit.blocker != null
