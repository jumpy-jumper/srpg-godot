class_name Summoner
extends PlayerUnit


export(Array, PackedScene) var followers = []


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


func _on_Stage_tile_clicked(tile):
	if selected and stage.get_unit_at(stage.get_world_position(tile)) == null:
		if stage.get_unit_at(stage.get_world_position(tile)) == null:
			stage.spawn_unit(followers[randi() % len(followers)], get_global_mouse_position())
			emit_signal("acted", self, "summoned.")
			selected = false
			emit_signal("deselected", self)
