class_name Follower
extends Unit


enum Facing {RIGHT, DOWN, LEFT, UP}

export(Facing) var facing = Facing.UP


func get_state():
	var state = .get_state()
	state["facing"] = facing
	return state

