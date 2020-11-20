class_name SetCurRoundCommand
extends Command


var stage: Stage
var prev: int
var new: int


func _init(stage: Stage, value: int) -> void:
	self.stage = stage
	prev = stage.cur_round
	new = value


func execute():
	.execute()
	stage.cur_round = new


func undo():
	.undo()
	stage.cur_round = prev
