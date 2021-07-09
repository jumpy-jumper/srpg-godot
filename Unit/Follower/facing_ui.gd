extends Node2D

onready var unit = $".."


export var standby_alpha = 0.5
onready var default_alpha = $Right.modulate.a


func _ready():
	visible = true


func _process(_delta):
	var children = get_children()
	
	var cur = children[posmod(unit.facing, 360) / 90]
	for node in children:
		if node == cur:
			node.modulate.a = 1 if unit.waiting_for_facing else default_alpha
		else:
			node.modulate.a = standby_alpha if unit.waiting_for_facing else 0
