class_name Stage
extends Node


signal unit_hovered(unit)
signal unit_clicked(unit)
signal terrain_hovered(terrain)
signal round_advanced(cur_round)
signal round_started(cur_round)
signal unit_greenlit(unit)

class State:
	var cur_round
	var order
	var unit_states = {}

const GRID_SIZE: int = 64
static func GET_POSITION_IN_GRID(pos):
	pos.x = floor(pos.x / GRID_SIZE) * GRID_SIZE
	pos.y = floor(pos.y / GRID_SIZE) * GRID_SIZE
	return pos

var cur_round = 0
var order = []
var snapshots = []


func _ready():
	for cat in $Units.get_children():
		for u in cat.get_children():
			connect_with_unit(u)
			match cat.name:
				"Ally":
					u.type = Unit.UnitType.ALLY
				"Enemy":
					u.type = Unit.UnitType.ENEMY
				"Neutral":
					u.type = Unit.UnitType.NEUTRAL
	snapshots.append(get_state())


func connect_with_unit(unit):
	unit.stage = self
	unit.connect("done", self, "_on_Unit_done")
	unit.connect("acted", self, "_on_Unit_acted")
	connect("round_advanced", unit, "_on_Stage_round_advanced")
	connect("round_started", unit, "_on_Stage_round_started")
	connect("unit_greenlit", unit, "_on_Stage_unit_greenlit")
	connect("unit_hovered", unit, "_on_Stage_unit_hovered")
	connect("unit_clicked", unit, "_on_Stage_unit_clicked")
	connect("terrain_hovered", unit, "_on_Stage_terrain_hovered")
	$Cursor.connect("position_hovered", unit, "_on_Cursor_position_hovered")
	$Cursor.connect("position_clicked", unit, "_on_Cursor_position_clicked")


func _process(_delta):
	if cur_round == 0 and Input.is_action_just_pressed("ui_accept"):
		yield(get_tree(), "idle_frame")
		next_unit()
		snapshots.append(get_state())
	elif len(snapshots) > 1 and Input.is_action_just_pressed("ui_cancel"):
		snapshots.pop_back()
		load_state(snapshots.back())
		# last_state.free()
	$UI.visible = cur_round > 0
	$UI.update_order(self)
	print(len(snapshots))


func update_units():
	for u in get_units():
		u.ini_bonuses[Unit.IniBonusType.TERRAIN] = get_terrain_at(u.position).ini_bonus


func order_criteria(a, b):
	if a.get_ini() > b.get_ini():
		return true
	return false


func start_round():
	cur_round += 1
	emit_signal("round_started", cur_round)
	order = []
	for cat in $Units.get_children():
		for u in cat.get_children():
			if u.health != Unit.HealthLevels.UNCONSCIOUS:
				order.append(u)
	order.sort_custom(self, "order_criteria")
	emit_signal("unit_greenlit", order[0])


func next_unit():
	emit_signal("round_advanced", cur_round)
	if cur_round == 0:
		start_round()
	else:
		for i in range (len(order)):
			if order[i].greenlit:
				if i == len(order) - 1:
					start_round()
				else:
					emit_signal("unit_greenlit", order[i + 1])
				break


func get_unit_at(pos):
	for cat in $Units.get_children():
		for u in cat.get_children():
			if u.position == pos:
				return u
	return null


func get_units():
	var ret = []
	ret += $Units/Ally.get_children()
	ret += $Units/Enemy.get_children()
	ret += $Units/Neutral.get_children()
	return ret


func get_units_around(pos):
	var ret = {}
	var all = get_units()
	for u in all:
		ret[(u.position - pos) / GRID_SIZE] = u
	return ret


func get_terrain_at(pos):
	for t in $Terrain.get_children():
		if t.position == pos:
			return t
	return null


func get_terrain_around(pos):
	var ret = {}
	var all = $Terrain.get_children()
	for t in all:
		ret[(t.position - pos) / GRID_SIZE] = t
	return ret


func get_state():
	var ret = State.new()
	ret.cur_round = cur_round
	ret.order = order
	for u in get_units():
		ret.unit_states[u] = u.get_state()
	return ret


func load_state(state):
	cur_round = state.cur_round
	order = state.order
	for u in state.unit_states.keys():
		u.load_state(state.unit_states[u])


func _on_Cursor_position_changed(pos):
	var unit = get_unit_at(pos)
	var terrain = get_terrain_at(pos)

	emit_signal("unit_hovered", unit)
	emit_signal("terrain_hovered", terrain)


func _on_Cursor_position_clicked(pos):
	emit_signal("unit_clicked", get_unit_at(pos))


func _on_Unit_acted():
	update_units()
	snapshots.append(get_state())


func _on_Unit_done():
	yield(get_tree(), "idle_frame")
	update_units()
	next_unit()
	snapshots.append(get_state())

