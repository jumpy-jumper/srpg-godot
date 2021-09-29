extends Skill


export var bonus_atk_step = 0.4
export var bonus_atk_max = 6.7
var bonus_atk = 0.0


onready var base_description = description


func _process(_delta):
	description = base_description + " (Current: +" + str(round(bonus_atk*100) + 70.0) + "%)" if bonus_atk > 0 else base_description
	unit.get_node("Sprite/Ready").modulate = Color.cyan if bonus_atk == bonus_atk_max else Color.white


func tick():
	.tick()
	if not is_active() and is_available():
		bonus_atk = min(bonus_atk_max, bonus_atk_step + bonus_atk)
	

func activate():
	base_skill_range = unit.get_basic_attack().base_skill_range
	var pre = base_target_count
	base_target_count = 129873129837
	deal(unit.get_stat("atk") * (0.7 + bonus_atk))
	base_target_count = pre
	.activate()


func deactivate():
	.deactivate()
	bonus_atk = 0.0


###############################################################################
#        State                                                                #
###############################################################################


func get_state():
	var ret = .get_state()
	ret["bonus_atk_step"] = bonus_atk_step
	ret["bonus_atk_max"] = bonus_atk_max
	ret["bonus_atk"] = bonus_atk
	ret["base_description"] = base_description
	return ret


func load_state(state):
	.load_state(state)
	bonus_atk_step = state["bonus_atk_step"]
	bonus_atk_max = state["bonus_atk_max"]
	bonus_atk = state["bonus_atk"]
	base_description = state["base_description"]
