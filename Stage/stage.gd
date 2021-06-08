class_name Stage
extends Node


signal player_phase_started(cur_tick)
signal enemy_phase_started(cur_tick)
signal undo_issued()
signal redo_issued()


export(PackedScene) var summoner_template
export(PackedScene) var follower_template
export(PackedScene) var gate_template
export(PackedScene) var enemy_template
export(Array, Resource) var terrain_types


###############################################################################
#        Main logic	                                                          #
###############################################################################


func _ready():
	for cat in $Level/Units.get_children():
		for cat2 in cat.get_children():
			for u in cat2.get_children():
				connect_with_unit(u)

	$Cursor.stage = self

	start_player_phase()


func _process(_delta):
	if Input.is_action_just_pressed("debug_state_log"):
		for i in range (len(state_description)) :
			print(("> " if i == cur_state_index else "  ") + state_description[i])
		print()


func _input(event):
	if event.is_action_pressed("undo"):
		undo()
	elif event.is_action_pressed("redo"):
		if unit_acted_this_tick:
			advance_tick()
		elif cur_state_index < len(states) - 1:
			redo()
		else:
			advance_tick()


func _on_Cursor_confirm_issued(pos):
	pass


func _on_Cursor_cancel_issued(pos):
	pass


func _on_Cursor_moved(pos):
	pass


func _on_Unit_acted(unit, description):
	unit_acted_this_tick = true


func _on_Unit_dead(unit):
	pass


###############################################################################
#        Getters                                                              #
###############################################################################


func get_cell_size():
	return $Level/Terrain.cell_size.x	# The grid is the same size in both axes.


# Returns the real-world position of the origin the tile in the given position.
func get_clamped_position(pos):
	return $Level/Terrain.map_to_world($Level/Terrain.world_to_map(pos))


func get_unit_at(pos):
	for cat in $Level/Units.get_children():
		for cat2 in cat.get_children():
			for u in cat2.get_children():
				if u.position == pos:
					return u
	return null


# Returns the terrain resource for the given real-world position.
func get_terrain_at(pos):
	var cell = $Level/Terrain.get_cellv($Level/Terrain.world_to_map(pos))
	return terrain_types[cell] if cell >= 0 else null


###############################################################################
#        Tick logic                                                          #
###############################################################################


var cur_tick = 0
var player_phase = true
var unit_acted_this_tick = false


func advance_tick():
	start_enemy_phase()
	for cat in $Level/Units/.get_children():
		for cat2 in cat.get_children():
			for unit in cat2.get_children():
				unit.tick()
	start_player_phase()


func start_player_phase():
	cur_tick += 1
	unit_acted_this_tick = false
	emit_signal("player_phase_started", cur_tick)
	append_state("Tick " + str(cur_tick) + " started.")


func start_enemy_phase():
	emit_signal("enemy_phase_started", cur_tick)


###############################################################################
#        Unit logic                                                           #
###############################################################################


var selected_unit = null


func select_unit(unit):
	selected_unit = unit


func deselect_unit():
	selected_unit = null


func connect_with_unit(unit):
	unit.stage = self
	unit.connect("acted", self, "_on_Unit_acted")
	unit.connect("dead", self, "_on_Unit_dead")
	connect("player_phase_started", unit, "_on_Stage_player_phase_started")
	connect("enemy_phase_started", unit, "_on_Stage_enemy_phase_started")
	$Cursor.connect("confirm_issued", unit, "_on_Cursor_confirm_issued")
	$Cursor.connect("cancel_issued", unit, "_on_Cursor_cancel_issued")
	$Cursor.connect("moved", unit, "_on_Cursor_moved")
	$Cursor.connect("hovered", unit, "_on_Cursor_hovered")
	

func add_unit(unit, pos):
	if unit is Summoner:
			$Level/Units/Player/Summoners.add_child(unit)
			unit.operatable = player_phase
	elif unit is Follower:
			$Level/Units/Player/Followers.add_child(unit)
			unit.operatable = player_phase
	elif unit is Gate:
			$Level/Units/Enemy/Gates.add_child(unit)
	elif unit is Enemy:
			$Level/Units/Enemy/Enemies.add_child(unit)
	
	unit.global_position = get_clamped_position(pos)
	connect_with_unit(unit)


###############################################################################
#        State data, undo and redo                                            #
###############################################################################


var states = []
var state_description = []
var cur_state_index = -1


func get_state():
	var units = []
	for cat in $Level/Units.get_children():
		for cat2 in cat.get_children():
			for u in cat2.get_children():
				units.append(to_json(u.get_state()))

	var state = {
		"cur_tick" : cur_tick,
		"player_phase" : player_phase,
		"units" : units,
	}

	return state


func append_state(description):
	yield(get_tree(), "idle_frame")
	cur_state_index += 1
	while len(states) > cur_state_index:
		states.pop_back()
		state_description.pop_back()
	states.append(get_state())
	state_description.append(description)


func load_state(state):
	cur_tick = state["cur_tick"]
	player_phase = state["player_phase"]

	for cat in $Level/Units.get_children():
		for cat2 in cat.get_children():
			for u in cat2.get_children():
				u.queue_free()

	for u in state["units"]:
		u = parse_json(u)
		var unit
		if u["unit_type"] == Unit.UnitType.SUMMONER:
				unit = summoner_template.instance()
				$Level/Units/Player/Summoners.add_child(unit)
		elif u["unit_type"] == Unit.UnitType.FOLLOWER:
				unit = follower_template.instance()
				$Level/Units/Player/Followers.add_child(unit)
		elif u["unit_type"] == Unit.UnitType.GATE:
				unit = gate_template.instance()
				$Level/Units/Enemy/Gates.add_child(unit)
		elif u["unit_type"] == Unit.UnitType.ENEMY:
				unit = enemy_template.instance()
				$Level/Units/Enemy/Enemies.add_child(unit)

		connect_with_unit(unit)
		unit.load_state(u)
		
	deselect_unit()


func undo():
	if unit_acted_this_tick:
		load_state(states[cur_state_index])
		unit_acted_this_tick = false
	elif cur_state_index > 0:
		load_state(states[cur_state_index - 1])
		cur_state_index -= 1
		
	emit_signal("undo_issued")


func redo():
	if cur_state_index < len(states) - 1:
		load_state(states[cur_state_index + 1])
		cur_state_index += 1
		
	emit_signal("redo_issued")
