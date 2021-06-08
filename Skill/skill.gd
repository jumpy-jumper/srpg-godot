extends Node
class_name Skill


onready var unit = $"../.."


###############################################################################
#        State logic                                                          #
###############################################################################


func get_state():
	var state = {
		"node_name" : name,
		"script_path" : get_script().get_path()
	}
	return state


func load_state(state):
	for v in state.keys():
		set(v, state[v])
	name = state["node_name"]
