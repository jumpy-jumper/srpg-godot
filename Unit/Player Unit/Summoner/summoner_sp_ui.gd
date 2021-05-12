extends Label


onready var unit = $"../.."


func _process(_delta):
	text = str(unit.sp)
