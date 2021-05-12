class_name Summoner
extends PlayerUnit


export(Array, Resource) var followers = []


func get_unit_type():
	return UnitType.SUMMONER


func get_state():
	var state = .get_state()
	state["followers"] = []
	for r in followers:
		state["followers"].append(r.resource_path)
	return state


func load_state(state):
	.load_state(state)
	followers = []
	for r in state["followers"]:
		followers.append(load(r))


func _on_Cursor_confirm_issued(pos):
	._on_Cursor_confirm_issued(pos)
	var unit = followers[randi() % len(followers)].instance()
	if stage.selected_unit == self \
		and stage.get_unit_at(pos) == null \
		and stage.get_terrain_at(pos) in unit.deployable_terrain:
			stage.add_unit(unit, get_global_mouse_position())
			emit_signal("acted", self, "summoned.")
			stage.selected_unit = null
	else:
		unit.free()
