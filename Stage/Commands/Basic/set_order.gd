class_name SetOrderCommand
extends Command


var stage: Stage
var prev: Array
var new: Array


func _init(stage: Stage, value: Array) -> void:
	self.stage = stage
	prev = stage._order
	new = value


func execute():
	.execute()
	stage._order = new


func undo():
	.undo()
	stage._order = prev
