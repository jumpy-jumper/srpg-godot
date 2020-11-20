extends Node


onready var _stage : Stage = $"../.."
onready var _panels : Node = $"Unit Panels"
onready var _round : Label = $"Round Counter"

func _process(_delta: float) -> void:
	_round.text = str(_stage.cur_round)
	var panels : Array = _panels.get_children()
	for i in range (len(panels)):
		panels[i].cur_unit = _stage.order[i] if i < len(_stage.order) else null
		panels[i].current = panels[i].cur_unit == _stage.cur_unit
