extends Label


onready var unit = $"../.."

var disabled = false


func _ready():
	disabled = not visible


func _process(_delta):
	visible = unit.blocker == null and not disabled
	text = str(unit.movement)
