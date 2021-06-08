extends TargetedSkill


enum SkillType { ATTACK, HEAL }

export(SkillType) var skill_type = SkillType.ATTACK

export(Unit.DamageType) var damage_type = Unit.DamageType.PHYSICAL


func tick():
	match skill_type:
		SkillType.ATTACK:
			for target in select_targets(get_units_in_range_of_type(unit.get_type_of_enemy())):
				target.take_damage(unit.base_atk, damage_type)
