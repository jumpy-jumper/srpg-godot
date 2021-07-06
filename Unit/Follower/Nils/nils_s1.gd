extends Skill

func tick():
	.tick()
	if is_active():
		unit.summoner.recover_faith(1)
