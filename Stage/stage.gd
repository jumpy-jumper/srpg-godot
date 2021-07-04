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


func _process(_delta):
	$"UI/Follower Panels".update_ui()


func _input(event):
	if event.is_action_pressed("next_follower"):
		selected_follower_index = (selected_follower_index + 1) % len(summoners_cache[0].followers)
	elif event.is_action_pressed("previous_follower"):
		selected_follower_index = posmod(selected_follower_index - 1, len(summoners_cache[0].followers))
	elif event.is_action_pressed("redo"):
		advance_tick()


func _on_Unit_dead(unit):
	if unit is Enemy:
		independent_enemies_cache.erase(unit)
	elif unit is Summoner:
		$Cursor.operatable = false
		$"UI/Game Over".visible = true


func _on_Cursor_confirm_issued(pos):
	if get_unit_at(pos) == null:	
		var summoner = summoners_cache[selected_summoner_index]	
		var unit = summoner.followers[selected_follower_index]
		if get_terrain_at(pos) in unit.deployable_terrain:
			if unit.cost <= summoner.faith and not unit.alive:
				unit.alive = true
				unit.global_position = get_clamped_position(pos)
				summoner.faith -= unit.cost
				deselect_unit()
#		else:
#			advance_tick()


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
	#unit.connect("acted", self, "_on_Unit_acted")
	unit.connect("dead", self, "_on_Unit_dead")
	connect("player_phase_started", unit, "_on_Stage_player_phase_started")
	connect("enemy_phase_started", unit, "_on_Stage_enemy_phase_started")
	$Cursor.connect("confirm_issued", unit, "_on_Cursor_confirm_issued")
	$Cursor.connect("cancel_issued", unit, "_on_Cursor_cancel_issued")
	$Cursor.connect("moved", unit, "_on_Cursor_moved")
	$Cursor.connect("hovered", unit, "_on_Cursor_hovered")
