class_name Summoner
extends PlayerUnit


export(Array, Resource) var followers = []


###############################################################################
#        Main logic                                                           #
###############################################################################


func _on_Cursor_confirm_issued(pos):
	._on_Cursor_confirm_issued(pos)
	var unit = followers[randi() % len(followers)].instance()
	if stage.selected_unit == self \
			and stage.get_unit_at(pos) == null \
			and stage.get_terrain_at(pos) in unit.deployable_terrain:
				stage.add_unit(unit, stage.get_node("Cursor").position)
				sp -= unit.cost
				emit_signal("acted", self, "summoned " + unit.unit_name + " at " + str(pos))
				stage.deselect_unit()
	else:
		unit.free()


func _on_Cursor_cancel_issued(pos):
	._on_Cursor_cancel_issued(pos)
	if stage.selected_unit == self:
		stage.deselect_unit()


###############################################################################
#        Tick and basic action                                                #
###############################################################################


func tick():
	for skill in $Skills.get_children():
		skill.tick()


###############################################################################
#        State logic                                                          #
###############################################################################


func get_type_of_self():
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
