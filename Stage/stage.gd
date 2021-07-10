class_name Stage
extends Node


signal player_phase_started(cur_tick)
signal enemy_phase_started(cur_tick)
signal undo_issued()
signal redo_issued()
signal tick_ended()


export(Array, Resource) var terrain_types


var summoners_cache = []
var gates_cache = []
var independent_followers_cache = []
var independent_enemies_cache = []


onready var level = Game.level_to_load.instance()
onready var terrain = level.get_node("Terrain")
onready var cursor = $Cursor


var selected_summoner_index = 0
var selected_follower_index = 0
var summoned_order = []


###############################################################################
#        Main logic	                                                          #
###############################################################################

func _ready():
	add_child(level)

	for u in level.get_children():
		if u is Unit:
			connect_with_unit(u)
			if u is Summoner:
				summoners_cache.append(u)
				for f in u.followers:
					level.add_child(f)
					connect_with_unit(f)
			elif u is Gate:
				if len(u.enemies.values()) > 0:
					u.path = get_path_to_target(u.position, get_selected_summoner().position, \
						u.enemies.values()[0].traversable)
				else:
					u.path = []
				gates_cache.append(u)
				for e in u.enemies.values():
					level.add_child(e)
					connect_with_unit(e)
			elif u is Enemy:
				independent_enemies_cache.append(u)
				summoned_order.append(u)
			elif u is Follower:
				independent_followers_cache.append(u)
				summoned_order.append(u)

	$Cursor.stage = self
	
	append_state()

# Control state:
var pending_ui = 0 # UI that is being hovered over
# $"UI/Unit UI".visible
# is_alive()
# is_waiting_for_facing()
# $CameraController.operatable

func is_alive():
	for summoner in summoners_cache:
		if not summoner.alive:
			return false
	return true


func is_waiting_for_facing():
	for summ in summoners_cache:
		for unit in summ.followers:
			if unit.waiting_for_facing:
				return true
	return false


func is_any_follower_previewing():
	for summ in summoners_cache:
		for unit in summ.followers:
			if unit.previewing:
				return true
	return false


func is_waiting_for_ui():
	return not (not $"UI/Unit UI".visible or $"UI/Unit UI".visible and $"UI/Unit UI".modulate.a == 0)


func can_select_follower_ui():
	return not is_waiting_for_ui() and is_alive()


func can_show_unit_ui():
	return not is_waiting_for_ui() and not $CameraController.operatable and is_alive()


func can_update_facing():
	return not is_waiting_for_ui() and is_alive()


func can_undo_or_redo():
	return not is_waiting_for_ui() \
		and not $CameraController.operatable


func can_move_cursor():
	return pending_ui == 0 \
		and is_alive() \
		and not is_waiting_for_ui() \
		and not is_waiting_for_facing() \
		and not $CameraController.operatable


func can_show_cursor():
	return pending_ui == 0 \
		and is_alive() \
		and not is_waiting_for_ui() \
		and not $CameraController.operatable


func can_change_selected_follower():
	return pending_ui == 0 \
		and is_alive() \
		and not is_waiting_for_ui() \
		and not $CameraController.operatable


func can_move_camera():
	return is_alive() \
		and not is_waiting_for_ui() \


func can_move_camera_with_cancel():
	return Game.move_camera_with_cancel \
		and can_move_camera() \
		and not get_unit_at(cursor.position) \
		and not is_any_follower_previewing()


func _process(_delta):
	if can_show_cursor():
		if can_move_cursor():
			cursor.control_state = cursor.ControlState.FREE
		else:
			cursor.control_state = cursor.ControlState.LOCKED
	else:
		cursor.control_state = cursor.ControlState.HIDDEN

	$"UI/Follower Panels".update_ui()
	$"UI/Game Over".visible = not is_alive()


func _input(event):
	if can_change_selected_follower():
		if event.is_action_pressed("next_follower"):
			selected_follower_index = (selected_follower_index + 1) % len(get_selected_summoner().followers)
		elif event.is_action_pressed("previous_follower"):
			selected_follower_index = posmod(selected_follower_index - 1, len(get_selected_summoner().followers))
	
	if can_show_unit_ui():
		if event.is_action_pressed("unit_ui"):
			var unit = get_unit_at($Cursor.position)
			if unit:
				show_unit_ui(unit)
			else:
				show_unit_ui(get_selected_summoner().followers[selected_follower_index])
		
	if can_undo_or_redo():
		if event.is_action_pressed("undo"):
			undo()
		elif event.is_action_pressed("redo"):
			redo()
		elif event.is_action_pressed("advance_round"):
			advance_tick()
		elif event.is_action_pressed("restart"):
			if Game.undoable_restart:
				load_state(states[0])
				append_state()
				$UI/Blackscreen.animate()
			else:
				get_tree().reload_current_scene()
			
	if event.is_action_pressed("debug_clear_pending_ui"):
		pending_ui = 0


func _on_Cursor_confirm_issued(pos):
	pass


func _on_Cursor_cancel_issued(pos):
	var unit = get_unit_at(pos)
	if unit:
		show_unit_ui(unit)
	else:
		var selected_follower = get_selected_follower()
		if selected_follower and selected_follower.previewing:
			show_unit_ui(selected_follower)


func show_unit_ui(unit):
	$"UI/Unit UI".update_unit(unit)
	$"UI/Unit UI".show()

func _on_UI_mouse_entered():
	pending_ui += 1

func _on_UI_mouse_exited():
	pending_ui -= 1


func _on_Skill_UI_skill_activation_requested(skill):
	if skill.is_available():
		skill.activate()
		yield(get_tree(), "idle_frame")
		$"UI/Unit UI".update_unit($"UI/Unit UI".saved_unit)


func _on_Unit_dead(unit):
	pass


func _on_Retreat_pressed():
	var unit = $"UI/Unit UI".saved_unit
	unit.die()
	append_state()
	$"UI/Unit UI".hide()


func _on_Unit_UI_exited():
	pass


###############################################################################
#        Getters                                                              #
###############################################################################


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
		for unit in gate.enemies.values():
			enemies_cache.append(unit)
	return summoners_cache + followers_cache + independent_followers_cache \
	+ enemies_cache + independent_enemies_cache + gates_cache


func get_units_of_type(type):
	match(type):
		Unit.UnitType.SUMMONER:
			return summoners_cache
		Unit.UnitType.GATE:
			return gates_cache
		Unit.UnitType.FOLLOWER:
			var followers_cache = []
			for summoner in summoners_cache:
				for unit in summoner.followers:
					followers_cache.append(unit)
			return followers_cache + independent_followers_cache
		Unit.UnitType.ENEMY:
			var enemies_cache = []
			for gate in gates_cache:
				for unit in gate.enemies.values():
					enemies_cache.append(unit)
			return enemies_cache + independent_enemies_cache


func get_selected_follower():
	if len(get_selected_summoner().followers) > 0:
		return get_selected_summoner().followers[selected_follower_index]
	else:
		return null


func get_selected_summoner():
	return summoners_cache[selected_summoner_index]


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
enum TickState { ACTION, MOVEMENT }
var tick_state = TickState.ACTION

func advance_tick():
	var followers = []
	var enemies = []
	for unit in summoned_order:
		if unit is Follower:
			followers.append(unit)
		if unit is Enemy:
			enemies.append(unit)
	var all_units = get_all_units()
	
	if tick_state == TickState.ACTION:
		for u in followers:
			if u.alive:
				u.block_enemies()
		
		for u in all_units:
			if u.alive:
				u.tick_skills()
		tick_state = TickState.MOVEMENT
		append_state()
		if Game.automatically_move_enemies:
			advance_tick()
	elif tick_state == TickState.MOVEMENT:
		for u in enemies:
			if u.alive:
				u.move()
		
		for u in followers:
			u.clear_block()
		
		for u in gates_cache:
			if u.alive:
				u.spawn_enemy()
		
		emit_signal("tick_ended")

		cur_tick += 1
		replace_last_state()
		tick_state = TickState.ACTION


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
	unit.connect("dead", self, "_on_Unit_dead")
	connect("player_phase_started", unit, "_on_Stage_player_phase_started")
	connect("enemy_phase_started", unit, "_on_Stage_enemy_phase_started")
	connect("tick_ended", unit, "_on_Stage_tick_ended")
	$Cursor.connect("confirm_issued", unit, "_on_Cursor_confirm_issued")
	$Cursor.connect("cancel_issued", unit, "_on_Cursor_cancel_issued")
	$Cursor.connect("moved", unit, "_on_Cursor_moved")
	$Cursor.connect("hovered", unit, "_on_Cursor_hovered")


###############################################################################
#        State and undo                                                       #
###############################################################################


var states = []
var cur_state_index = -1

#I will be moving most of this to their own classes eventually
func get_state():
	var ret = {}
	ret["cur_tick"] = cur_tick
	ret["summoned_order"] = [] + summoned_order
	for unit in get_all_units():
		var unit_state = {}
		unit_state["position"] = unit.position
		unit_state["alive"] = unit.alive
		unit_state["hp"] = unit.hp
		unit_state["shield"] = unit.shield
		match unit.get_type_of_self():
			unit.UnitType.FOLLOWER:
				unit_state["facing"] = unit.facing
				unit_state["cooldown"] = unit.cooldown
			unit.UnitType.SUMMONER:
				unit_state["faith"] = unit.faith
			unit.UnitType.ENEMY:
				unit_state["movement"] = unit.movement
				unit_state["blocked"] = unit.get_node("Blocked").visible
			unit.UnitType.GATE:
				unit_state["blocked"] = unit.get_node("Blocked").visible
				unit_state["path"] = unit.path + []
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
	cur_tick = state["cur_tick"]
	summoned_order = state["summoned_order"]
	tick_state = TickState.ACTION
	for unit in get_all_units():
		for status in unit.get_node("Statuses").get_children():
			status.queue_free()
		unit.position = state[unit]["position"]
		unit.alive = state[unit]["alive"]
		unit.hp = state[unit]["hp"]
		unit.shield = state[unit]["shield"]
		unit.toasts_this_tick = 0
		match unit.get_type_of_self():
			unit.UnitType.FOLLOWER:
				unit.facing = state[unit]["facing"]
				unit.cooldown = state[unit]["cooldown"]
				unit.waiting_for_facing = false
			unit.UnitType.SUMMONER:
				unit.faith = state[unit]["faith"]
			unit.UnitType.ENEMY:
				unit.movement = state[unit]["movement"]
				unit.get_node("Blocked").visible = state[unit]["blocked"]
			unit.UnitType.GATE:
				unit.get_node("Blocked").visible = state[unit]["blocked"]
				unit.path = state[unit]["path"]
		for skill in unit.get_node("Skills").get_children():
			skill.sp = state[skill]["sp"]
			skill.ticks_left = state[skill]["ticks_left"]
			if skill is Lysithea_S1:
				skill.bonus_atk = state[skill]["bonus_atk"]
				if skill.is_active():
					var bonus_atk_status = Status.new()
					bonus_atk_status.stat_additive_multipliers["atk"] = skill.bonus_atk
					skill.unit.get_node("Statuses").add_child(bonus_atk_status)
					skill.bonus_atk_status_cache = bonus_atk_status
			skill.update_statuses()


func append_state():
	cur_state_index += 1
	while len(states) > cur_state_index:
		states.pop_back()
	states.append(get_state())


# Used for very bad logic where the game needs to replace what it just did
func replace_last_state():
	states.pop_back()
	cur_state_index -= 1
	append_state()


func undo():
	if cur_state_index > 0:
		load_state(states[cur_state_index - 1])
		cur_state_index -= 1


func redo():
	if cur_state_index < len(states) - 1 and Game.redo_enabled:
		load_state(states[cur_state_index + 1])
		cur_state_index += 1
	else:
		advance_tick()
