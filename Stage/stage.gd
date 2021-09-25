class_name Stage
extends Node


signal player_phase_started(cur_tick)
signal enemy_phase_started(cur_tick)
signal undo_issued()
signal redo_issued()
signal tick_started()
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

var follower_groups = {}
var selected_summoner_index = 0
var selected_follower_index = 0
var summoned_order = []


###############################################################################
#        Control state                                                        #
###############################################################################

var pending_ui = 0

func is_alive():
	for summoner in summoners_cache:
		if not summoner.alive:
			return false
	return true


func is_won():
	return cur_level_index >= len(level.advance)


func is_waiting_for_user():
	for summ in summoners_cache:
		for unit in summ.followers:
			if unit.waiting_for_user:
				return true
	return false


func is_any_follower_previewing():
	for summ in summoners_cache:
		for unit in summ.followers:
			if unit.previewing:
				return true
	return false


func is_waiting_for_ui():
	for ui in $"Foreground UI".get_children():
		if ui.operatable:
			return true
	return false

func is_unit_with_name_alive(name):
	for unit in get_all_units():
		if unit.alive and unit.unit_name == name:
			return true
	return false


func can_select_follower_ui():
	return not is_waiting_for_ui() \
		and is_alive() \
		and not is_won()


func can_show_ui():
	return not is_waiting_for_ui()


func can_hide_ui():
	return is_waiting_for_ui() \


var camera_position_after_cancel_pressed = Vector2.ZERO
var camera_zoom_after_cancel_pressed = Vector2.ZERO
func can_show_unit_ui_with_cancel():
	return can_show_ui() \
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
		and not is_won() \
		and not is_waiting_for_user() \
		and not camera.operatable


func can_move_cursor():
	return pending_ui == 0 \
		and is_alive() \
		and not is_won() \
		and not is_waiting_for_ui() \
		and not is_waiting_for_user() \
		and not camera.operatable


func can_show_cursor():
	return pending_ui == 0 \
		and is_alive() \
		and not is_won() \
		and not is_waiting_for_ui() \
		and not camera.operatable


func can_change_selected_follower():
	return pending_ui == 0 \
		and is_alive() \
		and not is_won() \
		and not is_waiting_for_ui() \
		and not camera.operatable


func can_move_camera():
	return is_alive() \
		and not is_won() \
		and not is_waiting_for_ui() \
		and pending_ui == 0


func can_move_camera_with_cancel():
	return Game.move_camera_with_cancel \
		and can_move_camera()


###############################################################################
#        Main logic	                                                          #
###############################################################################


func _ready():
	add_child(level)
	
	# Why not do this inside the respective classes?!
	# Well, you see, the stage initializes after all of its children.
	for u in level.get_children():
		if u is Unit:
			connect_with_unit(u)
			if u is Summoner:
				summoners_cache.append(u)
				for f in u.followers:
					level.add_child(f)
					connect_with_unit(f)
					if not follower_groups.has(f.unit_name):
						follower_groups[f.unit_name] = {}
					follower_groups[f.unit_name][f.wind] = f
			elif u is Gate:
				u.initialize_path()
				gates_cache.append(u)
				terrain.connect("settings_changed", u, "_on_Terrain_settings_changed")
				for e in u.enemies.values():
					level.add_child(e)
					connect_with_unit(e)
					e.position = u.position
			elif u is Enemy:
				independent_enemies_cache.append(u)
				summoned_order.append(u.name)
			elif u is Follower:
				independent_followers_cache.append(u)
				summoned_order.append(u.name)
				if not follower_groups.has(u.unit_name):
					follower_groups[u.unit_name] = {}
				follower_groups[u.unit_name][u.wind] = u
			if u.alive:
				unit_pos_cache[u.position] = u

	$"UI/Follower Panels".initialize_ui()
	
	for group in follower_groups.values():
		for unit in group.values():
			unit.group = group.values()
	
	cursor.stage = self
	camera.position = level.default_camera_position
	camera.zoom = level.default_camera_zoom
	
	emit_signal("tick_started")
	
	append_state()


func _process(_delta):
	process_input()
	
	if can_show_cursor():
		if can_move_cursor():
			cursor.control_state = cursor.ControlState.FREE
		else:
			cursor.control_state = cursor.ControlState.LOCKED
	else:
		cursor.control_state = cursor.ControlState.HIDDEN
	
	$UI.scale = Vector2.ZERO if is_waiting_for_ui() else Vector2.ONE
	
	$"UI/Follower Panels".update_ui()
	
	
	if cur_level_index < len(level.advance):
		$"UI/Game Over".visible = not is_alive()
		$"UI/Game Over/Label".text = "YOU LOSE :("
	else:
		$"UI/Game Over".visible = true
		$"UI/Game Over/Label".text = "YOU WIN :D"
	
	var selected_follower = get_selected_follower()
	$Deployable.visible = selected_follower.can_be_deployed() if selected_follower else false
	if $Deployable.visible:
		$Deployable.update_tiles(get_selected_follower().deployable_terrain)
		# Big performance bottleneck, but fine for now


func process_input():
	if Input.is_action_just_pressed("debug_save"):
		save_file()
	elif Input.is_action_just_pressed("debug_load"):
		load_file()

	if (Input.is_action_just_pressed("keyboard_cancel") \
		and not Input.is_action_pressed("control") \
		or Input.is_action_just_released("mouse_cancel")) \
		and can_hide_ui():
			for ui in $"Foreground UI".get_children():
				if ui.operatable:
					ui.hide()
	
	elif (Input.is_action_just_released("mouse_cancel") \
		and Game.settings["cursor_mouse_controls"] \
		and can_show_unit_ui_with_cancel() \
		or Input.is_action_just_pressed("keyboard_examine")) \
		and can_show_ui():
			var unit = get_unit_at($Cursor.position)
			if unit:
				show_unit_ui(unit)
			elif get_selected_follower():
				show_unit_ui(get_selected_follower())
				
	elif Input.is_action_just_pressed("mouse_cancel"):
		camera_position_after_cancel_pressed = $Camera2D.position
		camera_zoom_after_cancel_pressed = $Camera2D.zoom
	
	elif Input.is_action_just_pressed("keyboard_examine") and $"Foreground UI/Unit UI".operatable:
		$"Foreground UI/Unit UI".hide()
			
	elif Input.is_action_just_pressed("debug_clear_pending_ui"):
		pending_ui = 0
			
	elif Input.is_action_just_pressed("debug_burn_rn"):
		print(get_randf())
	
	elif InputWatcher.is_action_pressed_with_rapid_fire("keyboard_next") and can_change_selected_follower():
		selected_follower_index = (selected_follower_index + 1) % len(follower_groups)
	elif InputWatcher.is_action_pressed_with_rapid_fire("keyboard_previous") and can_change_selected_follower():
		selected_follower_index = posmod(selected_follower_index - 1, len(follower_groups))
			
	elif InputWatcher.is_action_pressed_with_rapid_fire("keyboard_undo") and can_undo_or_redo():
		undo()
		
	elif InputWatcher.is_action_pressed_with_rapid_fire("keyboard_redo") and can_undo_or_redo():
		redo()
		
	elif (InputWatcher.is_action_pressed_with_rapid_fire("keyboard_restart") \
		or (InputWatcher.is_action_pressed_with_rapid_fire("mouse_restart"))) \
		and can_undo_or_redo():
			if Game.settings["undoable_restart"]:
				load_state(states[0])
				append_state()
				$"Foreground UI/Blackscreen".animate()
			else:
				get_tree().reload_current_scene()
	
	elif InputWatcher.is_action_pressed_with_rapid_fire("keyboard_advance") and can_advance_round():
		advance_tick()
	
	elif Input.is_action_just_pressed("keyboard_escape"):
		if can_show_ui() and not $"Foreground UI/Settings".operatable:
			$"Foreground UI/Settings".show()
		elif $"Foreground UI/Settings".operatable:
			$"Foreground UI/Settings".hide()

func _input(event):
	if can_undo_or_redo() and event.is_action_pressed("mouse_undo"):
		undo()
	elif can_undo_or_redo() and event.is_action_pressed("mouse_redo"):
		redo()
	elif can_advance_round() and event.is_action_pressed("mouse_advance"):
		advance_tick()


func _on_Cursor_confirm_issued(pos):
	pass


func _on_Cursor_cancel_issued(pos):
	pass


var unit_pos_cache = {}


func _on_Unit_dead(unit):
	unit_pos_cache.erase(unit.position)


func _on_Unit_moved(unit, from):
	if unit_pos_cache.has(from):
		unit_pos_cache.erase(from)
	unit_pos_cache[unit.position] = unit


func show_unit_ui(unit):
	$"Foreground UI/Unit UI".update_unit(unit)
	$"Foreground UI/Unit UI".show()	


func _on_UI_mouse_entered():
	pending_ui += 1


func _on_UI_mouse_exited():
	pending_ui -= 1

func _on_Skill_UI_skill_activation_requested(skill):
	if is_instance_valid(skill) and skill.is_available():
		skill.activate()
		yield(get_tree(), "idle_frame")
		$"Foreground UI/Unit UI".update_unit($"Foreground UI/Unit UI".saved_unit)


func _on_Retreat_pressed():
	var unit = $"Foreground UI/Unit UI".saved_unit
	unit.die()
	append_state()
	$"Foreground UI/Unit UI".hide()


func _on_Unit_UI_exited():
	pass


func _on_Settings_Button_gui_input(event):
	if event is InputEventMouseButton and not event.pressed and can_show_ui() and not $"Foreground UI/Settings".operatable:
		$"Foreground UI/Settings".show()

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

func get_enemy_count():
	var count = 0
	for e in independent_enemies_cache:
		count += 1
	for g in gates_cache:
		count += len(g.enemies.keys())
	return count

func get_enemies_left():
	var count = 0
	for e in independent_enemies_cache:
		if e.alive:
			count += 1
	for g in gates_cache:
		for key in g.enemies.keys():
			if key >= cur_tick:
				count += 1
			elif g.enemies[key].alive:
				count += 1
	return count


func get_selected_follower():
	return $"UI/Follower Panels".get_children()[selected_follower_index].get_cur_unit()


func get_selected_summoner():
	return summoners_cache[selected_summoner_index]


func get_unit_at(pos):
	if unit_pos_cache.has(pos):
		return unit_pos_cache[pos]
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
		unit = level.get_node(unit)
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
			u.tick_statuses()
	
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
	selected_summoner_index = (selected_summoner_index + 1) % len(summoners_cache)
	cur_seed = INITIAL_SEED
	for i in range(cur_tick):
		cur_seed = rand_seed(cur_seed)[1]
	
	emit_signal("tick_started")
	append_state()


var cur_level_index = 0

func advance_level():
	cur_level_index += 1
	if not (cur_level_index >= len(level.advance)):
		for summoner in summoners_cache:
			summoner.get_level_advancing_skill().base_skill_cost = level.advance[cur_level_index]


###############################################################################
#        RNG                                                                  #
###############################################################################


const INITIAL_SEED = 3310532886983200000
var cur_seed = INITIAL_SEED

func get_rn():
	seed(cur_seed)
	cur_seed = rand_seed(cur_seed)[1]
	var ret = cur_seed
	randomize()
	return ret

func get_randb():
	seed(get_rn())
	var ret = randf() > 0.5
	randomize()
	return ret

func get_randi(end, start=0):
	seed(get_rn())
	var ret = (randi() % (end-start)) + start
	randomize()
	return ret

func get_randf():
	seed(get_rn())
	var ret = randf()
	randomize()
	return ret


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
	unit.connect("moved", self, "_on_Unit_moved")
	connect("player_phase_started", unit, "_on_Stage_player_phase_started")
	connect("enemy_phase_started", unit, "_on_Stage_enemy_phase_started")
	connect("tick_started", unit, "_on_Stage_tick_started")
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
	ret["cur_level_index"] = cur_level_index
	ret["summoned_order"] = [] + summoned_order
	ret["cur_seed"] = cur_seed
	for unit in get_all_units():
		var unit_state = unit.get_state()
		for key in unit_state:
			ret[unit.name + "\t" + key] = unit_state[key]
	return ret


func get_state_diff(initial, final):
	var ret = {}
	for key in initial.keys():
		if key in final and initial[key] != final[key]:
			ret[key] = final[key]
	return ret


func load_state(state):
	cur_tick = state["cur_tick"]
	cur_level_index = state["cur_level_index"]
	summoned_order = state["summoned_order"]
	cur_seed = state["cur_seed"]
	unit_pos_cache.clear()
	selected_summoner_index = (cur_tick - 1) % len(summoners_cache)
	
	var unit_states = {}
	for key in state.keys():
		if "\t" in key:
			var split = key.split("\t")
			if not unit_states.has(split[0]):
				unit_states[split[0]] = {}
			unit_states[split[0]][key.trim_prefix(split[0] + "\t")] = state[key]
	
	for unit in get_all_units():
		unit.load_state(unit_states[unit.name])
		if unit.alive:
			unit_pos_cache[unit.position] = unit


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


func save_file():
	var save_data = []
	for i in range(cur_state_index):
		save_data.append(get_state_diff(states[i], states[i+1]))
		
	var save_file = File.new()
	save_file.open("user://dit_debug_save.sav", File.WRITE)
	save_file.store_line(var2str(save_data))
	save_file.close()
	

func load_file():
	var save_data = []
	var save_file = File.new()
	save_file.open("user://dit_debug_save.sav", File.READ)
	save_data = str2var(save_file.get_as_text())
	
	var first_state = states[0].duplicate()
	states.clear()
	states.append(first_state)
	
	for i in range(len(save_data)):
		states.append(states[i].duplicate())
		for key in save_data[i]:
			states[i+1][key] = save_data[i][key]
	
	cur_state_index = len(save_data)
	load_state(states[cur_state_index])
