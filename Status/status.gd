extends Node
class_name Status


var issuer_unit = null
var issuer_name = ""
export var persists_through_death = false
export var independent_from_skill = false
export(Dictionary) var stat_overwrites = {}
export(Dictionary) var stat_flat_bonuses = {}
export(Dictionary) var stat_additive_multipliers = {}
export(Dictionary) var stat_multiplicative_multipliers = {}


func tick():
	pass


func get_state():
	var ret = {}
	ret["script"] = get_script().get_path()
	ret["name"] = name
	ret["issuer_unit"] = issuer_unit
	ret["issuer_name"] = issuer_name
	ret["persists_through_death"] = persists_through_death
	ret["independent_from_skill"] = independent_from_skill
	ret["stat_overwrites"] = var2str(stat_overwrites)
	ret["stat_flat_bonuses"] = var2str(stat_flat_bonuses)
	ret["stat_additive_multipliers"] = var2str(stat_additive_multipliers)
	ret["stat_multiplicative_multipliers"] = var2str(stat_multiplicative_multipliers)
	return ret


func load_state(state):
	name = state["name"]
	issuer_unit = state["issuer_unit"]
	issuer_name = state["issuer_name"]
	persists_through_death = state["persists_through_death"]
	independent_from_skill = state["independent_from_skill"]
	stat_overwrites = str2var(state["stat_overwrites"])
	stat_flat_bonuses = str2var(state["stat_flat_bonuses"])
	stat_additive_multipliers = str2var(state["stat_additive_multipliers"])
	stat_multiplicative_multipliers = str2var(state["stat_multiplicative_multipliers"])
