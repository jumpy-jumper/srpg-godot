extends Skill

func activate():
	.activate()
	unit.stage.get_selected_summoner().recover_faith(1)
	print("ABURAAAAAGE")
