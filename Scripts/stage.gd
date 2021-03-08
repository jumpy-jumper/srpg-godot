class_name Stage
extends Node


signal player_phase_started(cur_round)
signal enemy_phase_started(cur_round)
signal tile_hovered(tile)
signal tile_clicked(tile)
signal unit_hovered(unit)
signal unit_clicked(unit)
signal terrain_hovered(terrain)
signal terrain_clicked(terrain)

export(PackedScene) var summoner_template
export(PackedScene) var follower_template
export(PackedScene) var gate_template
export(PackedScene) var enemy_template
export(Array, Resource) var terrain_types

var cur_round = 0
var player_phase = true
var snapshots = []


func get_position_in_grid(pos):
	return $Terrain.map_to_world($Terrain.world_to_map(pos))


func get_tilemap_position(pos):
	return $Terrain.world_to_map(pos)

func get_world_position(pos):
	return $Terrain.map_to_world(pos)


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

	snapshots.append(get_state())


func _process(_delta):
	$UI.visible = cur_round > 0
	$UI.update_unit(get_unit_at($Cursor.position))
	$UI.update_terrain(get_terrain_at($Cursor.position))


func start_player_phase():
	cur_round += 1
	emit_signal("player_phase_started", cur_round)


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
				$Units/Player/Gates.add_child(unit)
		elif u["unit_type"] == Unit.UnitType.ENEMY:
				unit = enemy_template.instance()
				$Units/PlayerEnemies.add_child(unit)

		connect_with_unit(unit)
		unit.load_state(u)


func connect_with_unit(unit):
	unit.stage = self
	unit.connect("acted", self, "_on_Unit_acted")
	unit.connect("dead", self, "_on_Unit_dead")
	connect("player_phase_started", unit, "_on_Stage_player_phase_started")
	connect("enemy_phase_started", unit, "_on_Stage_enemy_phase_started")
	connect("tile_hovered", unit, "_on_Stage_tile_hovered")
	connect("tile_clicked", unit, "_on_Stage_tile_clicked")
	connect("unit_hovered", unit, "_on_Stage_unit_hovered")
	connect("unit_clicked", unit, "_on_Stage_unit_clicked")


func _on_Cursor_moved(pos):
	emit_signal("terrain_hovered", get_terrain_at(pos))
	emit_signal("unit_hovered", get_unit_at(pos))
	emit_signal("tile_hovered", $Terrain.world_to_map(pos))


func _on_Cursor_confirm_issued(pos):
	emit_signal("terrain_clicked", get_terrain_at(pos))
	emit_signal("unit_clicked", get_unit_at(pos))
	emit_signal("tile_clicked", $Terrain.world_to_map(pos))


func _on_Cursor_cancel_issued(pos):
	if len(snapshots) > 1:
		snapshots.pop_back()
		load_state(snapshots.back())


func _on_Unit_acted():
	snapshots.append(get_state())

func _on_Unit_dead(unit):
	snapshots.append(get_state())
