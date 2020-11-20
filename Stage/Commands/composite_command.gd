class_name CompositeCommand
extends Command
# Composite commands do not change state on their own, but mantain a list
# of lower level commands that directly change state.
# Do not implement execute() or undo() in composite commands.


var commands: Array = []
var SetCurRoundCommand = preload("res://Stage/Commands/Basic/set_cur_round.gd")
var SetGreenlitCommand = preload("res://Stage/Commands/Basic/set_greenlit.gd")
var SetIniBaseCommand = preload("res://Stage/Commands/Basic/set_ini_base.gd")
var SetOrderCommand = preload("res://Stage/Commands/Basic/set_order.gd")


func execute():
	.execute()
	for c in commands:
		c.execute()


func undo():
	.undo()
	for i in range(len(commands) - 1, -1, -1):
		commands[i].undo()
