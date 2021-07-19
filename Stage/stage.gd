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
onready var camera = $Camera2D


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
				u.initialize_path()
				gates_cache.append(u)
				terrain.connect("settings_changed", u, "_on_Terrain_settings_changed")
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
# camera.operatable

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
	return not is_waiting_for_ui() and is_alive()


var camera_position_after_cancel_pressed = Vector2.ZERO
var camera_zoom_after_cancel_pressed = Vector2.ZERO
func can_show_unit_ui_with_cancel():
	return can_show_unit_ui() \
		and (get_unit_at(cursor.position) or is_any_follower_previewing()) \
		and abs((camera_position_after_cancel_pressed - $Camera2D.position).length()) < Game.unit_ui_with_cancel_leeway \
		and camera_zoom_after_cancel_pressed == $Camera2D.zoom


func can_update_facing():
	return not is_waiting_for_ui() and is_alive()


func can_undo_or_redo():
	return not is_waiting_for_ui() \
		and not camera.operatable


func can_advance_round():
	return not is_waiting_for_ui() \
		and not is_waiting_for_facing() \
		and not camera.operatable


func can_move_cursor():
	return pending_ui == 0 \
		and is_alive() \
		and not is_waiting_for_ui() \
		and not is_waiting_for_facing() \
		and not camera.operatable


func can_show_cursor():
	return pending_ui == 0 \
		and is_alive() \
		and not is_waiting_for_ui() \
		and not camera.operatable


func can_change_selected_follower():
	return pending_ui == 0 \
		and is_alive() \
		and not is_waiting_for_ui() \
		and not camera.operatable


func can_move_camera():
	return is_alive() \
		and not is_waiting_for_ui() \


func can_move_camera_with_cancel():
	return Game.move_camera_with_cancel \
		and can_move_camera()


func _process(_delta):	
	if Input.is_action_just_pressed("cancel") and not Input.is_action_pressed("control"):
		camera_position_after_cancel_pressed = $Camera2D.position
		camera_zoom_after_cancel_pressed = $Camera2D.zoom
	if can_show_unit_ui():
		var show_unit_ui_with_cancel_condition = can_show_unit_ui_with_cancel() \
			and Input.is_action_just_released("cancel") and not Input.is_action_pressed("control")
		if Input.is_action_just_pressed("unit_ui") or show_unit_ui_with_cancel_condition:
			var unit = get_unit_at($Cursor.position)
			if unit:
				show_unit_ui(unit)
			else:
				show_unit_ui(get_selected_summoner().followers[selected_follower_index])
			
	if Input.is_action_just_pressed("debug_clear_pending_ui"):
		pending_ui = 0
	
	if can_change_selected_follower():
		if InputWatcher.is_action_pressed_with_rapid_fire("next_follower"):
			selected_follower_index = (selected_follower_index + 1) % len(get_selected_summoner().followers)
		elif InputWatcher.is_action_pressed_with_rapid_fire("previous_follower"):
			selected_follower_index = posmod(selected_follower_index - 1, len(get_selected_summoner().followers))
			
	if can_undo_or_redo():
		if InputWatcher.is_action_pressed_with_rapid_fire("undo"):
			undo()
		elif InputWatcher.is_action_pressed_with_rapid_fire("redo"):
			redo()
		elif InputWatcher.is_action_pressed_with_rapid_fire("restart"):
			if Game.undoable_restart:
				load_state(states[0])
				append_state()
				$UI/Blackscreen.animate()
			else:
				get_tree().reload_current_scene()
	
	if can_advance_round():
		if InputWatcher.is_action_pressed_with_rapid_fire("advance_round"):
			advance_tick()
	
	if can_show_cursor():
		if can_move_cursor():
			cursor.control_state = cursor.ControlState.FREE
		else:
			cursor.control_state = cursor.ControlState.LOCKED
	else:
		cursor.control_state = cursor.ControlState.HIDDEN

	$"UI/Follower Panels".update_ui()
	$"UI/Game Over".visible = not is_alive()
	
	var selected_follower = get_selected_follower()
	$Deployable.visible = selected_follower.can_be_deployed()
	if $Deployable.visible:
		$Deployable.update_tiles(get_selected_follower().deployable_terrain)
		# Big performance bottleneck, but fine for now


func _input(event):
	if can_undo_or_redo() and event.is_action_pressed("undo_wheel"):
		undo()
	elif can_advance_round() and event.is_action_pressed("advance_round_wheel"):
		advance_tick()


func _on_Cursor_confirm_issued(pos):
	pass


func _on_Cursor_cancel_issued(pos):
	pass


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


func get_all_statuses():
	var ret = []
	for unit in get_all_units():
		for status in unit.get_node("Statuses").get_children():
			ret.append(status)
	return ret


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


func get_graph(traversable):
	var ret = []
	
	var all_tiles = terrain.get_used_cells()
	
	for pos in all_tiles:
		if terrain_types[terrain.get_cellv(pos)] in traversable:
			ret.append(terrain.map_to_world(pos))
	
	return ret


# Breadth-first search
func get_path_to_target(start, end, traversable):
	var points = get_graph(traversable)
	
	var visited = []
	var paths = [[start]]
	
	if start == end:
		return []
	
	while len(paths) > 0:
		var path = paths.pop_front()
		var node = path[len(path) - 1]
		if not node in visited:
			var adjacent = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
			for i in range(len(adjacent)):
				adjacent[i] *= get_cell_size()
				adjacent[i] += node
			for pos in adjacent:
				if pos in points:
					var new_path = [] + path
					new_path.append(pos)
					if pos == end:
						return new_path
					paths.append(new_path)
			visited.append(node)
	
	return []


###############################################################################
#        Tick logic                                                          #
###############################################################################


var cur_tick = 1

func advance_tick():
	var followers = []
	var enemies = []
	for unit in summoned_order:
		if unit is Follower:
			followers.append(unit)
		if unit is Enemy:
			enemies.append(unit)
	
	
	for u in followers:
		if u.alive:
			u.block_enemies()
	
	for u in summoners_cache + followers + enemies + gates_cache:
		if u.alive:
			u.tick_skills()
	
	for u in enemies:
		if u.alive:
			u.move()
	
	for u in followers:
		u.clear_block()
	
	for u in summoners_cache + followers + enemies + gates_cache:
		u.display_toasts()
	
	for u in gates_cache:
		if u.alive:
			u.spawn_enemy()
	
	emit_signal("tick_ended")

	cur_tick += 1
	append_state()


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


func get_state():
	var ret = {}
	ret["cur_tick"] = cur_tick
	ret["summoned_order"] = [] + summoned_order
	for unit in get_all_units():
		ret[unit] = unit.get_state()
	return ret


func load_state(state):
	cur_tick = state["cur_tick"]
	summoned_order = state["summoned_order"]
	for unit in get_all_units():
		unit.load_state(state[unit])


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
