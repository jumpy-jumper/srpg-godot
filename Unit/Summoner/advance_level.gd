extends Skill


func activate():
	unit.faith -= unit.get_stat("skill_cost", base_skill_cost)
	unit.stage.advance_level()
