extends TargetedSkill
class_name FollowerTargetedSkill


func get_skill_range():
	var ret = []
	for r in .get_skill_range():
		ret.append(r.rotated(deg2rad(unit.facing)).round())
	return ret
	

###############################################################################
#        State logic                                                          #
###############################################################################


func get_state():
	var state = .get_state()
	return state


func load_state(state):
	.load_state(state)
