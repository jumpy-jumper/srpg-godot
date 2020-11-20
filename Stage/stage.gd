class_name Stage
extends Node

signal unit_hovered(unit)
signal unit_clicked(unit)
signal terrain_hovered(terrain)
signal round_started(cur_round)
signal unit_greenlit(unit)

const GRID_SIZE: int = 64
static func GET_POSITION_IN_GRID(pos: Vector2) -> Vector2:
	pos.x = floor(pos.x / GRID_SIZE) * GRID_SIZE
	pos.y = floor(pos.y / GRID_SIZE) * GRID_SIZE
	return pos

var cur_round: int = 0
var _order: Array = []
var snapshots: Array = []


func _ready() -> void:
	for cat in $Units.get_children():
		for u in cat.get_children():
			_connect_with_unit(u)
			match cat.name:
				"Ally":
					u.type = Unit.UnitType.ALLY
				"Enemy":
					u.type = Unit.UnitType.ENEMY
				"Neutral":
					u.type = Unit.UnitType.NEUTRAL

	_start_round()
	snapshots.append(get_state())


func _connect_with_unit(unit: Unit) -> void:
	unit.connect("done", self, "_on_Unit_done")
	#connect("unit_hovered", unit, "_on_Stage_unit_hovered")
	connect("unit_clicked", unit, "_on_Stage_unit_clicked")
	#connect("terrain_hovered", unit, "_on_Stage_terrain_hovered")
	connect("round_started", unit, "_on_Stage_round_started")
	connect("unit_greenlit", unit, "_on_Stage_unit_greenlit")


func _process(_delta: float) -> void:
	$UI.update_order(self)
	if len(snapshots) > 0 and Input.is_action_just_pressed("ui_cancel"):
		var last_state: State = snapshots.pop_back()
		load_state(last_state)
		# last_state.free()


func _order_criteria(a, b) -> bool:
	if a.get_ini() > b.get_ini():
		return true
	return false


func _start_round() -> void:
	cur_round += 1
	_order = []
	for cat in $Units.get_children():
		for u in cat.get_children():
			if u.health != Unit.HealthLevels.UNCONSCIOUS:
				_order.append(u)
	_order.sort_custom(self, "_order_criteria")
	emit_signal("round_started", cur_round)
	emit_signal("unit_greenlit", _order[0])


func _next_unit() -> void:
	for i in range (len(_order)):
		if _order[i].greenlit:
			if i == len(_order) - 1:
				_start_round()
			else:
				emit_signal("unit_greenlit", _order[i + 1])
			break


func _get_unit_at(pos: Vector2) -> Unit:
	for cat in $Units.get_children():
		for u in cat.get_children():
			if u.position == pos:
				return u
	return null


func get_all_units() -> Array:
	var ret: Array = []
	ret += $Units/Ally.get_children()
	ret += $Units/Enemy.get_children()
	ret += $Units/Neutral.get_children()
	return ret


func _get_terrain_at(pos: Vector2) -> Terrain:
	for t in $Terrain.get_children():
		if t.position == pos:
			return t
	return null


class State:
	var cur_round: int
	var order: Array
	var unit_states: Dictionary # [Unit, Unit.State]


func get_state() -> State:
	var ret: State = State.new()
	ret.cur_round = cur_round
	ret.order = _order
	for u in get_all_units():
		ret.unit_states[u] = u.get_state()
	return ret


func load_state(state: State) -> void:
	cur_round = state.cur_round
	_order = state.order
	for u in state.unit_states.keys():
		u.load_state(state.unit_states[u])


func _on_Cursor_position_changed(pos: Vector2) -> void:
	var unit: Unit = _get_unit_at(pos)
	var terrain: Terrain = _get_terrain_at(pos)

	emit_signal("unit_hovered", unit)
	emit_signal("terrain_hovered", terrain)


func _on_Cursor_position_clicked(pos: Vector2) -> void:
	emit_signal("unit_clicked", _get_unit_at(pos))


func _on_Unit_done() -> void:
	snapshots.append(get_state())
	yield(get_tree(), "idle_frame")
	_next_unit()

