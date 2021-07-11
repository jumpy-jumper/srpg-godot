extends Skill


enum SkillType { ATTACK, HEAL }

export(SkillType) var skill_type = SkillType.ATTACK

export(Unit.DamageType) var damage_type = Unit.DamageType.PHYSICAL

export var base_attack_count = 1


var targeting_toast = preload("res://Unit/targeting_toast.tscn")


func activate():
	.activate()
	for i in range (unit.get_stat("attack_count", base_attack_count)):
		var skill_range = unit.get_stat("skill_range", base_skill_range)
		if skill_type == SkillType.ATTACK: 
			var possible_targets = []
			possible_targets = unit.get_units_in_range_of_type(skill_range, unit.get_type_of_enemy())
			
			# If this unit has [0, 0] in range, prioritize blockers / blocked units
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
				target.apply_damage(unit.get_stat("atk", unit.base_atk), \
					unit.get_stat("damage_type", damage_type))
	
				var toast = targeting_toast.instance()
				toast.attacker = unit
				toast.attackee = target
				toast.gradient = toast.gradient.duplicate()
				toast.gradient.set_color(1, unit.colors[damage_type])
				unit.toasts.append(toast)


		elif skill_type == SkillType.HEAL: 
			var possible_targets = []
			possible_targets += unit.get_units_in_range_of_type(skill_range, unit.get_type_of_self())
			for target in select_targets(possible_targets):
				target.apply_healing(unit.get_stat("atk", unit.base_atk))
