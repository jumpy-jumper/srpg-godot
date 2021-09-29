extends Skill


enum SkillType { ATTACK, HEAL }

export(SkillType) var skill_type = SkillType.ATTACK

export(Unit.DamageType) var damage_type = Unit.DamageType.PHYSICAL

export var base_attack_count = 1


func is_basic_attack():
	return true


func activate():
	.activate()
	var skill_range = get_stat("skill_range")
	for i in range (get_stat("attack_count")):
		if skill_type == SkillType.ATTACK: 
			var possible_targets = []
			possible_targets = unit.get_units_in_range_of_type(skill_range, unit.get_type_of_enemy())
			
			for unit in possible_targets + []:
				if unit.get_stat("invisible"):
					possible_targets.erase(unit)
			
			# If this unit has [0, 0] in attack range, also target blockers / blocked units
			if Vector2.ZERO in skill_range:
				match(unit.get_type_of_self()):
					unit.UnitType.FOLLOWER:
						for blocked in unit.blocked:
							if blocked in possible_targets:
								possible_targets.erase(blocked)
							possible_targets.push_front(blocked)
					unit.UnitType.ENEMY:
						if unit.blocker:
							if unit.blocker in possible_targets:
								possible_targets.erase(unit.blocker)
							possible_targets.push_front(unit.blocker)
						
			for target in select_targets(possible_targets):
				unit.deal_damage_to_target(target, unit.get_stat("atk"), get_stat("damage_type"))
		
		elif skill_type == SkillType.HEAL: 
			var possible_targets = []
			possible_targets += unit.get_units_in_range_of_type(skill_range, unit.get_type_of_self())
			for target in possible_targets + []:
				if target.is_full_hp() or target.get_stat("incoming_healing") == 0:
					possible_targets.erase(target)
			for target in select_targets(possible_targets):
				unit.deal_damage_to_target(target, unit.get_stat("atk"), get_stat("damage_type"))
		
		for skill in unit.get_node("Skills").get_children():
			if skill.recovery == skill.Recovery.OFFENSIVE:
				skill.sp += 1


###############################################################################
#        State                                                                #
###############################################################################


func get_state():
	var ret = .get_state()
	ret["skill_type"] = skill_type
	ret["damage_type"] = damage_type
	ret["base_attack_count"] = base_attack_count
	return ret


func load_state(state):
	.load_state(state)
	skill_type = state["skill_type"]
	damage_type = state["damage_type"]
	base_attack_count = state["base_attack_count"]
