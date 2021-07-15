extends Label


onready var unit = $"../../.."

var disabled = false


func _ready():
	disabled = not visible


func _process(_delta):
	text = str(unit.movement)
