extends Skill

func activate():
	.activate()
	unit.stage.get_selected_summoner().recover_faith(1)
	
	var pre = base_target_count
	base_target_count = 129873129837
	deal(unit.get_stat("atk") * 1.8)
	base_target_count = pre
