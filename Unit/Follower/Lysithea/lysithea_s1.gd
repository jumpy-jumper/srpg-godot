extends Skill
class_name Lysithea_S1


export var bonus_atk_step = 0.4
export var bonus_atk_max = 6.2
var bonus_atk = 0.0


onready var base_description = description


func _process(_delta):
	description = base_description + " (Current: +" + str(round(bonus_atk*100) + 70.0) + "%)" if bonus_atk > 0 else base_description


func tick():
	.tick()
	if not is_active() and is_available():
		bonus_atk = min(bonus_atk_max, bonus_atk_step + bonus_atk)
	

func activate():
	.activate()
	var bonus_atk_status = Status.new()
	bonus_atk_status.stat_additive_multipliers["atk"] = bonus_atk
	bonus_atk_status.issuer_unit = unit
	bonus_atk_status.issuer_name = name
	unit.get_node("Statuses").add_child(bonus_atk_status)
	unit.stage.replace_last_state()


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
