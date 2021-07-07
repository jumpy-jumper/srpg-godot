class_name Stage
extends Node


signal player_phase_started(cur_tick)
signal enemy_phase_started(cur_tick)
signal undo_issued()
signal redo_issued()


export(Array, Resource) var terrain_types


var summoners_cache = []
var gates_cache = []
var independent_followers_cache = []
var independent_enemies_cache = []


var level = null
var terrain = null


var selected_summoner_index = 0
var selected_follower_index = 0


###############################################################################
#        Main logic	                                                          #
###############################################################################


var paused = false


func _ready():
	assert(Game.level_to_load != null)
	add_child(Game.level_to_load.instance())
	
	level = get_tree().get_nodes_in_group("Level")[0]
	terrain = level.get_node("Terrain")

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
			elif u is Gate:
				for tick in u.enemies.keys():
					var enemy = u.enemies[tick].instance()
					u.enemies_cache[tick] = enemy
					level.add_child(enemy)
					enemy.alive = false
					enemy.gate = u
					connect_with_unit(enemy)
				gates_cache.append(u)
			elif u is Enemy:
				independent_enemies_cache.append(u)
			elif u is Follower:
				independent_followers_cache.append(u)

	$Cursor.stage = self
	
	append_state()


func _process(_delta):
	$Cursor.operatable = not paused and is_alive() and pending_ui == 0

	$"UI/Follower Panels".update_ui()
	$"UI/Game Over".visible = not is_alive()


func _input(event):
	if not paused:
		if is_alive():
			if event.is_action_pressed("next_follower"):
				selected_follower_index = (selected_follower_index + 1) % len(summoners_cache[0].followers)
			elif event.is_action_pressed("previous_follower"):
				selected_follower_index = posmod(selected_follower_index - 1, len(summoners_cache[0].followers))
		if event.is_action_pressed("undo"):
			undo()
		elif event.is_action_pressed("redo"):
			redo()
		elif event.is_action_pressed("restart"):
			if Game.undoable_restart:
				for unit in get_all_units():
					unit.marked = false
				load_state(states[0])
				append_state()
				$UI/Blackscreen.animate()
			else:
				get_tree().reload_current_scene()
		elif event.is_action_pressed("unit_ui"):
			var unit = get_unit_at($Cursor.position)
			if unit:
				show_unit_ui(unit)
			else:
				show_unit_ui(summoners_cache[selected_summoner_index].followers[selected_follower_index])
		elif event.is_action_pressed("debug_clear_pending_ui"):
			pending_ui = 0


func _on_Cursor_confirm_issued(pos):
	var flag = false
	for summ in summoners_cache:
		for unit in summ.followers:
			if unit.waiting_for_facing:
				flag = true

	if not flag:
		if get_unit_at(pos) == null:	
			var summoner = summoners_cache[selected_summoner_index]	
			var unit = summoner.followers[selected_follower_index]
			if get_terrain_at(pos) in unit.deployable_terrain \
				and unit.get_stat("cost", unit.base_cost) <= summoner.faith \
				and not unit.alive and unit.cooldown == 0:
					unit.alive = true
					unit.global_position = get_clamped_position(pos)
					summoner.faith -= unit.get_stat("cost", unit.base_cost)
					for skill in unit.get_node("Skills").get_children():
						skill.initialize()
					deselect_unit()
					acted_this_tick = true
					unit.waiting_for_facing = true
			else:
				advance_tick()


func _on_Cursor_cancel_issued(pos):
	show_unit_ui(get_unit_at(pos))


func show_unit_ui(unit):
	if not paused:
		if unit:
			$"UI/Unit UI".update_unit(unit)
			$"UI/Unit UI".show()
			paused = true

var pending_ui = 0

func _on_UI_mouse_entered():
	pending_ui += 1


func _on_UI_mouse_exited():
	pending_ui -= 1


func _on_Unit_UI_exited():
	paused = false


func _on_Skill_UI_skill_activation_requested(skill):
	if skill.is_available():
		skill.activate()
		yield(get_tree(), "idle_frame")
		$"UI/Unit UI".update_unit($"UI/Unit UI".saved_unit)


func _on_Unit_acted(unit):
	acted_this_tick = true


func _on_Unit_dead(unit):
	pass


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
	var enemies_cache = []
	for summoner in summoners_cache:
		for unit in summoner.followers:
			followers_cache.append(unit)
	for gate in gates_cache:
		for unit in gate.enemies_cache.values():
			enemies_cache.append(unit)
	return summoners_cache + followers_cache + independent_followers_cache \
	+ enemies_cache + independent_enemies_cache + gates_cache


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


func get_path_to_target(start, end, traversable):
	var astar = get_astar_graph(traversable)
	
	var path = astar.get_point_path(astar.get_closest_point(terrain.world_to_map(start)), 
		astar.get_closest_point(terrain.world_to_map(end)))

	var ret = []
	for v in path:
		ret.append(v * get_cell_size())
	return ret


###############################################################################
#        Tick logic                                                          #
###############################################################################


var cur_tick = 1


func advance_tick():
	for u in get_all_units():
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
				unit_state["cooldown"] = unit.cooldown
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
			if skill is Lysithea_S1:
				skill_state["bonus_atk"] = skill.bonus_atk
			ret[skill] = skill_state
	return ret


func load_state(state):
	acted_this_tick = false
	cur_tick = state["cur_tick"]
	for unit in get_all_units():
		for status in unit.get_node("Statuses").get_children():
			status.queue_free()
		unit.position = state[unit]["position"]
		unit.alive = state[unit]["alive"]
		unit.hp = state[unit]["hp"]
		match unit.get_type_of_self():
			unit.UnitType.FOLLOWER:
				unit.facing = state[unit]["facing"]
				unit.blocked = [] + state[unit]["blocked"]
				unit.cooldown = state[unit]["cooldown"]
				unit.waiting_for_facing = false
				unit.waiting_for_facing_flag = false
			unit.UnitType.SUMMONER:
				unit.faith = state[unit]["faith"]
			unit.UnitType.ENEMY:
				unit.movement = state[unit]["movement"]
				unit.blocker = state[unit]["blocker"]
		for skill in unit.get_node("Skills").get_children():
			skill.sp = state[skill]["sp"]
			skill.ticks_left = state[skill]["ticks_left"]
			if skill is Lysithea_S1:
				skill.bonus_atk = state[skill]["bonus_atk"]
			skill.update_statuses()


func append_state():
	cur_state_index += 1
	while len(states) > cur_state_index:
		states.pop_back()
	states.append(get_state())


func undo():
	if acted_this_tick:
		load_state(states[cur_state_index])
	elif cur_state_index > 0:
		load_state(states[cur_state_index - 1])
		cur_state_index -= 1


func redo():
	if cur_state_index < len(states) - 1 and Game.redo_enabled:
		load_state(states[cur_state_index + 1])
		cur_state_index += 1


func _on_Retreat_pressed():
	var unit = $"UI/Unit UI".saved_unit
	unit.die()
	unit.emit_signal("acted", unit)
	paused = false
	$"UI/Unit UI".hide()
