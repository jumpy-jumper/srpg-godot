extends Skill


func activate():
	unit.faith -= get_stat("skill_cost")
	unit.stage.advance_level()
