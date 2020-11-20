class_name SetGreenlitCommand
extends Command


var unit: Unit
var prev: bool
var new: bool


func _init(unit: Unit, value: bool) -> void:
	self.unit = unit
	prev = unit.greenlit
	new = value


func execute():
	.execute()
	unit.greenlit = new


func undo():
	.undo()
	unit.greenlit = prev
