class_name Summoner
extends PlayerUnit


export(Array, PackedScene) var followers = []


func get_unit_type():
	return UnitType.SUMMONER


func get_state():
	var state = .get_state()
	state["paths_to_followers"] = []
	for r in followers:
		state["paths_to_followers"].append(r.resource_path)
	return state


func load_state(state):
	.load_state(state)
	followers = []
	for r in state["paths_to_followers"]:
		followers.append(load(r))
