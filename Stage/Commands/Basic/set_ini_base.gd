class_name SetIniBaseCommand
extends Command


var unit: Unit
var prev: int
var new: int


func _init(unit: Unit, value: int) -> void:
	self.unit = unit
	prev = unit.ini_base
	new = value


func execute():
	.execute()
	unit.ini_base = new


func undo():
	.undo()
	unit.ini_base = prev
