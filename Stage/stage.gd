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
var order: Array = []
var snapshots: Array = []


func _ready() -> void:
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


func connect_with_unit(unit: Unit) -> void:
	unit.connect("done", self, "_on_Unit_done")
	#connect("unit_hovered", unit, "_on_Stage_unit_hovered")
	connect("unit_clicked", unit, "_on_Stage_unit_clicked")
	#connect("terrain_hovered", unit, "_on_Stage_terrain_hovered")
	connect("round_started", unit, "_on_Stage_round_started")
	connect("unit_greenlit", unit, "_on_Stage_unit_greenlit")
	$Cursor.connect("position_clicked", unit, "_on_Cursor_position_clicked")


func _process(_delta: float) -> void:
	if cur_round == 0 and Input.is_action_just_pressed("ui_accept"):
		yield(get_tree(), "idle_frame")
		snapshots.append(get_state())
		next_unit()
	elif len(snapshots) > 1 and Input.is_action_just_pressed("ui_cancel"):
		snapshots.pop_back()
		load_state(snapshots.back())
		# last_state.free()
	$UI.visible = cur_round > 0
	$UI.update_order(self)


func order_criteria(a, b) -> bool:
	if a.get_ini() > b.get_ini():
		return true
	return false


func start_round() -> void:
	cur_round += 1
	emit_signal("round_started", cur_round)
	order = []
	for cat in $Units.get_children():
		for u in cat.get_children():
			if u.health != Unit.HealthLevels.UNCONSCIOUS:
				order.append(u)
				u.ini_bonus = get_terrain_at(u.position).ini_multiplier
	order.sort_custom(self, "order_criteria")
	emit_signal("unit_greenlit", order[0])


func next_unit() -> void:
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
	snapshots.append(get_state())


func get_unit_at(pos: Vector2) -> Unit:
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


func get_terrain_at(pos: Vector2) -> Terrain:
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
	ret.order = order
	for u in get_all_units():
		ret.unit_states[u] = u.get_state()
	return ret


func load_state(state: State) -> void:
	cur_round = state.cur_round
	order = state.order
	for u in state.unit_states.keys():
		u.load_state(state.unit_states[u])


func _on_Cursor_position_changed(pos: Vector2) -> void:
	var unit: Unit = get_unit_at(pos)
	var terrain: Terrain = get_terrain_at(pos)

	emit_signal("unit_hovered", unit)
	emit_signal("terrain_hovered", terrain)


func _on_Cursor_position_clicked(pos: Vector2) -> void:
	emit_signal("unit_clicked", get_unit_at(pos))


func _on_Unit_done() -> void:
	next_unit()

