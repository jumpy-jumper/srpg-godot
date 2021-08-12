extends Skill

func tick():
	if is_active():
		unit.stage.get_selected_summoner().recover_faith(1)
	.tick()
