class_name Stage
extends Node


signal player_phase_started(cur_tick)
signal enemy_phase_started(cur_tick)
signal undo_issued()
signal redo_issued()


export(Array, Resource) var terrain_types


var summoners_cache = []
var independent_followers_cache = []
var independent_enemies_cache = []


onready var level = get_tree().get_nodes_in_group("Level")[0]
onready var terrain = level.get_node("Terrain")


var selected_summoner_index = 0
var selected_follower_index = 0


###############################################################################
#        Main logic	                                                          #
###############################################################################


func _ready():
	for u in level.get_children():
		if u is Unit:
			connect_with_unit(u)
			if u is Summoner:
				var followers_cache = []
				for unit in u.followers:
					unit = unit.instance()
					level.add_child(unit)
					followers_cache.append(unit)
					unit.alive = false
					unit.summoner = u
					connect_with_unit(unit)
				u.followers = followers_cache
				summoners_cache.append(u)
			elif u is Enemy:
				independent_enemies_cache.append(u)
			elif u is Follower:
				independent_followers_cache.append(u)

	$Cursor.stage = self
	
	append_state()


func _process(_delta):
	$"UI/Follower Panels".update_ui()
	
	$Cursor.operatable = is_alive()
	$"UI/Game Over".visible = not is_alive()


func _input(event):
	if is_alive():
		if event.is_action_pressed("next_follower"):
			selected_follower_index = (selected_follower_index + 1) % len(summoners_cache[0].followers)
		elif event.is_action_pressed("previous_follower"):
			selected_follower_index = posmod(selected_follower_index - 1, len(summoners_cache[0].followers))
		elif event.is_action_pressed("redo"):
			redo()
	if event.is_action_pressed("undo"):
		undo()
	elif event.is_action_pressed("restart"):
		if Game.undoable_restart:
			load_state(states[0])
			append_state()
		else:
			get_tree().reload_current_scene()


func _on_Cursor_confirm_issued(pos):
	if get_unit_at(pos) == null:	
		var summoner = summoners_cache[selected_summoner_index]	
		var unit = summoner.followers[selected_follower_index]
		if get_terrain_at(pos) in unit.deployable_terrain:
			if unit.get_stat("cost", unit.base_cost) <= summoner.faith and not unit.alive:
				unit.alive = true
				unit.global_position = get_clamped_position(pos)
				summoner.faith -= unit.get_stat("cost", unit.base_cost)
				for skill in unit.get_node("Skills").get_children():
					skill.initialize()
				deselect_unit()
				acted_this_tick = true
	elif get_unit_at(pos).get_type_of_self() == Unit.UnitType.SUMMONER:
		advance_tick()


func _on_Unit_acted(unit):
	acted_this_tick = true


###############################################################################
#        Getters                                                              #
###############################################################################


func is_alive():
	for summoner in summoners_cache:
		if not summoner.alive:
			return false
	return true

func get_cell_size():
	return terrain.cell_size.x	# The grid is the same size in both axes.


# Returns the real-world position of the origin the tile in the given position.
func get_clamped_position(pos):
	return terrain.map_to_world(terrain.world_to_map(pos))


func get_all_units():
	var followers_cache = []
	for summoner in summoners_cache:
		for unit in summoner.followers:
			followers_cache.append(unit)
	return summoners_cache + followers_cache \
		+ independent_followers_cache + independent_enemies_cache


func get_unit_at(pos):
	for u in get_all_units():
		if u.alive and u.position == pos:
			return u
	return null


# Returns the terrain resource for the given real-world position.
func get_terrain_at(pos):
	var cell = terrain.get_cellv(terrain.world_to_map(pos))
	return terrain_types[cell] if cell >= 0 else null


func get_astar_graph(traversable_tiles):
	var astar = AStar2D.new()
	
	var all_tiles = terrain.get_used_cells()
	
	for pos in all_tiles:
		if terrain_types[terrain.get_cellv(pos)] in traversable_tiles:
			astar.add_point(astar.get_available_point_id(), pos)
	
	var adjacent = [Vector2(0, 1), Vector2(1, 0)]
	for p in astar.get_points():
		for a in adjacent:
			var closest = astar.get_closest_point(astar.get_point_position(p) + a)
			if (astar.get_point_position(closest) - astar.get_point_position(p)).length() == 1:
				astar.connect_points(p, closest)


	return astar


###############################################################################
#        Tick logic                                                          #
###############################################################################


var cur_tick = 1


func advance_tick():
	for u in get_all_units():
		if u.alive:
			u.tick()
	cur_tick += 1
	append_state()
	acted_this_tick = false


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



###############################################################################
#        State and undo                                                       #
###############################################################################


var states = []
var cur_state_index = -1
var acted_this_tick = false


func get_state():
	var ret = {}
	ret["cur_tick"] = cur_tick
	for unit in get_all_units():
		var unit_state = {}
		unit_state["position"] = unit.position
		unit_state["alive"] = unit.alive
		unit_state["hp"] = unit.hp
		match unit.get_type_of_self():
			unit.UnitType.FOLLOWER:
				unit_state["facing"] = unit.facing
				unit_state["blocked"] = [] + unit.blocked
			unit.UnitType.SUMMONER:
				unit_state["faith"] = unit.faith
			unit.UnitType.ENEMY:
				unit_state["movement"] = unit.movement
				unit_state["blocker"] = unit.blocker
		ret[unit] = unit_state
		for skill in unit.get_node("Skills").get_children():
			var skill_state = {}
			skill_state["sp"] = skill.sp
			skill_state["ticks_left"] = skill.ticks_left
			ret[skill] = skill_state
	return ret


func load_state(state):
	acted_this_tick = false
	cur_tick = state["cur_tick"]
	for unit in get_all_units():
		unit.position = state[unit]["position"]
		unit.alive = state[unit]["alive"]
		unit.hp = state[unit]["hp"]
		match unit.get_type_of_self():
			unit.UnitType.FOLLOWER:
				unit.facing = state[unit]["facing"]
				unit.blocked = [] + state[unit]["blocked"]
			unit.UnitType.SUMMONER:
				unit.faith = state[unit]["faith"]
			unit.UnitType.ENEMY:
				unit.movement = state[unit]["movement"]
				unit.blocker = state[unit]["blocker"]
		for skill in unit.get_node("Skills").get_children():
			skill.sp = state[skill]["sp"]
			skill.ticks_left = state[skill]["ticks_left"]
			skill.update_statuses()


func append_state():
	cur_state_index += 1
	while len(states) > cur_state_index:
		states.pop_back()
	states.append(get_state())


func undo():
	if cur_state_index > 0:
		load_state(states[cur_state_index - 1])
		cur_state_index -= 1


func redo():
	if acted_this_tick:
		advance_tick()
	elif cur_state_index < len(states) - 1:
		load_state(states[cur_state_index + 1])
		cur_state_index += 1
	else:
		advance_tick()
