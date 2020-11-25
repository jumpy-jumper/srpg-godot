class_name Stage
extends Node


signal unit_hovered(unit)
signal unit_clicked(unit)
signal terrain_hovered(terrain)
signal round_advanced(cur_round)
signal round_started(cur_round)
signal unit_greenlit(unit)

export(PackedScene) var default_unit

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
			cat.remove_child(u)
			$Units.add_child(u)
			order.append(u)
		cat.free()

	snapshots.append(get_state())


func connect_with_unit(unit):
	unit.stage = self
	unit.connect("acted", self, "_on_Unit_acted")
	unit.connect("dead", self, "_on_Unit_dead")
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

	$UI.visible = cur_round > 0
	$UI.update_order(self)


func update_units():
	for u in order:
		var t = get_terrain_at(u.position)
		if t:
			u.ini_bonuses[Unit.IniBonusType.TERRAIN] = t.ini_bonus


func order_criteria(a, b):
	return a.get_ini() > b.get_ini()


func start_round():
	cur_round += 1
	emit_signal("round_started", cur_round)
	order = []
	for u in $Units.get_children():
		order.append(u)
	order.sort_custom(self, "order_criteria")
	update_units()
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
	for u in order:
		if u.position == pos:
			return u
	return null


func get_terrain_at(pos):
	for t in $Terrain.get_children():
		if t.position == pos:
			return t
	return null


class State:
	var cur_round
	var order
	var unit_states = []


func get_state():
	var ret = State.new()
	ret.cur_round = cur_round
	for u in order:
		ret.unit_states.append(u.get_state())
	return ret


func load_state(state):
	cur_round = state.cur_round
	var previous = order
	order = []
	for s in state.unit_states:
		var new = default_unit.instance()
		new.load_state(s)
		$Units.add_child(new)
		connect_with_unit(new)
		order.append(new)
	yield(get_tree(), "idle_frame")
	for u in previous:
		u.free()


func _on_Cursor_position_changed(pos):
	var unit = get_unit_at(pos)
	var terrain = get_terrain_at(pos)

	emit_signal("unit_hovered", unit)
	emit_signal("terrain_hovered", terrain)


func _on_Cursor_position_clicked(pos):
	emit_signal("unit_clicked", get_unit_at(pos))


func _on_Unit_acted(done):
	update_units()
	if done:
		yield(get_tree(), "idle_frame")
		next_unit()
	snapshots.append(get_state())


func _on_Unit_dead(unit):
	order.remove(order.find(unit))
	update_units()
	if unit.greenlit:
		next_unit()
		snapshots.append(get_state())
