class_name Stage
extends Node


signal player_phase_started(cur_round)
signal enemy_phase_started(cur_round)
signal undo_issued()
signal redo_issued()


export(PackedScene) var summoner_template
export(PackedScene) var follower_template
export(PackedScene) var gate_template
export(PackedScene) var enemy_template
export(Array, Resource) var terrain_types

var cur_round = 0
var player_phase = true

var states = []
var state_description = []
var cur_state_index = -1


var selected_unit = null


func get_cell_size():
	return $Terrain.cell_size().x


func clamp_to_grid(pos):
	return $Terrain.map_to_world($Terrain.world_to_map(pos))


func get_unit_at(pos):
	for cat in $Units.get_children():
		for cat2 in cat.get_children():
			for u in cat2.get_children():
				if u.position == pos:
					return u
	return null


func get_terrain_at(pos):
	var cell = $Terrain.get_cellv($Terrain.world_to_map(pos))
	return terrain_types[cell] if cell >= 0 else null


func _ready():
	for cat in $Units.get_children():
		for cat2 in cat.get_children():
			for u in cat2.get_children():
				connect_with_unit(u)

	$Cursor.stage = self

	start_player_phase()


func _process(_delta):
	if Input.is_action_just_pressed("undo"):
		undo()
	elif Input.is_action_just_pressed("redo"):
		redo()
	
	if Input.is_action_just_pressed("debug_state_log"):
		for i in range (len(state_description)) :
			print(("> " if i == cur_state_index else "  ") + state_description[i])
		print()


func start_player_phase():
	cur_round += 1
	emit_signal("player_phase_started", cur_round)
	append_state("Round " + str(cur_round) + " started.")


func start_enemy_phase():
	emit_signal("enemy_phase_started", cur_round)


func get_state():
	var units = []
	for cat in $Units.get_children():
		for cat2 in cat.get_children():
			for u in cat2.get_children():
				units.append(to_json(u.get_state()))

	var state = {
		"cur_round" : cur_round,
		"player_phase" : player_phase,
		"units" : units,
	}

	return state


func load_state(state):
	cur_round = state["cur_round"]
	player_phase = state["player_phase"]

	for cat in $Units.get_children():
		for cat2 in cat.get_children():
			for u in cat2.get_children():
				u.queue_free()


	for u in state["units"]:
		u = parse_json(u)
		var unit
		if u["unit_type"] == Unit.UnitType.SUMMONER:
				unit = summoner_template.instance()
				$Units/Player/Summoners.add_child(unit)
		elif u["unit_type"] == Unit.UnitType.FOLLOWER:
				unit = follower_template.instance()
				$Units/Player/Followers.add_child(unit)
		elif u["unit_type"] == Unit.UnitType.GATE:
				unit = gate_template.instance()
				$Units/Enemy/Gates.add_child(unit)
		elif u["unit_type"] == Unit.UnitType.ENEMY:
				unit = enemy_template.instance()
				$Units/Enemy/Enemies.add_child(unit)

		connect_with_unit(unit)
		unit.load_state(u)
	selected_unit = null


func add_unit(unit, pos):
	if unit.get_unit_type() == Unit.UnitType.SUMMONER:
			$Units/Player/Summoners.add_child(unit)
			unit.operatable = player_phase
	elif unit.get_unit_type() == Unit.UnitType.FOLLOWER:
			$Units/Player/Followers.add_child(unit)
			unit.operatable = player_phase
	elif unit.get_unit_type() == Unit.UnitType.GATE:
			$Units/Enemy/Gates.add_child(unit)
	elif unit.get_unit_type() == Unit.UnitType.ENEMY:
			$Units/Enemy/Enemies.add_child(unit)
	
	unit.global_position = clamp_to_grid(pos)
	connect_with_unit(unit)


func connect_with_unit(unit):
	unit.stage = self
	unit.connect("acted", self, "_on_Unit_acted")
	unit.connect("dead", self, "_on_Unit_dead")
	connect("player_phase_started", unit, "_on_Stage_player_phase_started")
	connect("enemy_phase_started", unit, "_on_Stage_enemy_phase_started")
	$Cursor.connect("confirm_issued", unit, "_on_Cursor_confirm_issued")
	$Cursor.connect("cancel_issued", unit, "_on_Cursor_cancel_issued")


func select(unit):
	selected_unit = unit


func deselect():
	selected_unit = null


func undo():
	if cur_state_index > 0:
		load_state(states[cur_state_index - 1])
		cur_state_index -= 1
	emit_signal("undo_issued")


func redo():
	if cur_state_index < len(states) - 1:
		load_state(states[cur_state_index + 1])
		cur_state_index += 1
	emit_signal("redo_issued")


func append_state(description):
	yield(get_tree(), "idle_frame")
	cur_state_index += 1
	while len(states) > cur_state_index:
		states.pop_back()
		state_description.pop_back()
	states.append(get_state())
	state_description.append(description)


func _on_Cursor_moved(pos):
	pass


func _on_Cursor_confirm_issued(pos):
	if not get_unit_at(pos):
		start_enemy_phase()
		for follower in $Units/Player/Followers.get_children():
			follower.act()
		for enemy in $Units/Enemy/Enemies.get_children():
			enemy.act()
		start_player_phase()


func _on_Cursor_cancel_issued(pos):
	pass


func _on_Unit_acted(unit, description):
	append_state("[" + unit.unit_name + "] " + description)
