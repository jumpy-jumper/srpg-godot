extends Skill

func activate():
	.activate()
	unit.stage.get_selected_summoner().recover_faith(1)
	
	var pre = base_target_count
	base_target_count = 129873129837
	for target in select_targets(unit.get_units_in_range_of_type(get_stat("skill_range"), unit.get_type_of_enemy())):
		unit.deal_damage_to_target(target, unit.get_stat("atk") * 1.8, unit.get_basic_attack().get_stat("damage_type"))
	base_target_count = pre
