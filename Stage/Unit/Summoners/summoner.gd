class_name Summoner
extends Unit


export(Array, PackedScene) var followers = []


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
