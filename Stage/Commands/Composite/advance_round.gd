class_name AdvanceRoundCommand
extends CompositeCommand

var stage: Stage

func _init(stage: Stage) -> void:
	self.stage = stage
	var greenlit: Unit = null
	for u in stage.get_all_units():
		if u.greenlit:
			greenlit = u

	if greenlit == null:
		new_round(stage)
	else:
		commands.append(SetGreenlitCommand.new(greenlit, false))
		for i in range (len(stage._order)):
			if stage._order[i] == greenlit:
				if i == len(stage._order) - 1:
					new_round(stage)
				else:
					commands.append(SetGreenlitCommand.new(stage._order[i + 1], true))
				break


# Recalculate unit order and reset their base initiative
func new_round(stage: Stage) -> void:
	commands.append(SetCurRoundCommand.new(stage, stage.cur_round + 1))

	var order: Array = []
	for u in stage.get_all_units():
		commands.append(SetIniBaseCommand.new(u, round_start_ini(stage, u)))
		order.append(u)
	order.sort_custom(stage, "order_criteria")

	commands.append(SetOrderCommand.new(stage, order))
	commands.append(SetGreenlitCommand.new(order[0], true))


func round_start_ini(s:Stage, u: Unit) -> int:
	return u.stats[Unit.CombatStats.FOR] + s.cur_round + 1


func order_criteria(a: Unit, b: Unit) -> bool:
	if a.round_start_ini() * a.ini_bonus > b.round_start_ini() * a.ini_bonus:
		return true
	return false
