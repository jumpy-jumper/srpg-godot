extends Skill


enum SkillType { ATTACK, HEAL }

export(SkillType) var skill_type = SkillType.ATTACK

export(Unit.DamageType) var damage_type = Unit.DamageType.PHYSICAL


func tick():
	match skill_type:
		SkillType.ATTACK:
			for target in get_targets(get_units_in_range_of_type(Unit.UnitType.ENEMY)):
				target.take_damage(unit.base_atk, damage_type)
