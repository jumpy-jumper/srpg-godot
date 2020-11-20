class_name Stage
extends Node

signal unit_hovered(unit)
signal unit_clicked(unit)
signal terrain_hovered(terrain)
signal round_started()
signal unit_greenlit(unit)

const GRID_SIZE: int = 64
static func GET_POSITION_IN_GRID(pos: Vector2) -> Vector2:
	pos.x = floor(pos.x / GRID_SIZE) * GRID_SIZE
	pos.y = floor(pos.y / GRID_SIZE) * GRID_SIZE
	return pos

var cur_round: int = 0
var cur_unit: Unit = null

var _order: Array = []

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
	emit_signal("unit_greenlit", cur_unit)

func _connect_with_unit(unit: Unit) -> void:
	unit.connect("done", self, "_on_Unit_done")
	connect("unit_hovered", unit, "_on_Stage_unit_hovered")
	connect("unit_clicked", unit, "_on_Stage_unit_clicked")
	connect("terrain_hovered", unit, "_on_Stage_terrain_hovered")
	connect("round_started", unit, "_on_Stage_round_started")
	connect("unit_greenlit", unit, "_on_Stage_unit_greenlit")

func _process(_delta: float) -> void:
	$UI.update_order(self)


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
	cur_unit = _order[0]
	emit_signal("round_started")


func _next_unit() -> void:
	for i in range (len(_order)):
		if _order[i] == cur_unit:
			if i == len(_order) - 1:
				_start_round()
			else:
				cur_unit = _order[i + 1]
			break


func _get_unit_at(pos: Vector2) -> Unit:
	for cat in $Units.get_children():
		for u in cat.get_children():
			if u.position == pos:
				return u
	return null


func _get_terrain_at(pos: Vector2) -> Terrain:
	for t in $Terrain.get_children():
		if t.position == pos:
			return t
	return null


func _on_Cursor_position_changed(pos: Vector2) -> void:
	var unit: Unit = _get_unit_at(pos)
	var terrain: Terrain = _get_terrain_at(pos)

	emit_signal("unit_hovered", unit)
	emit_signal("terrain_hovered", terrain)


func _on_Cursor_position_clicked(pos: Vector2) -> void:
	emit_signal("unit_clicked", _get_unit_at(pos))


func _on_Unit_done() -> void:
	_next_unit()
	emit_signal("unit_greenlit", cur_unit)

