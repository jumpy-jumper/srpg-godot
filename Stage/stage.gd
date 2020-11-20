class_name Stage
extends Node

signal unit_hovered(unit)
signal unit_clicked(unit)
signal terrain_hovered(terrain)

const GRID_SIZE: int = 64
static func GET_POSITION_IN_GRID(pos: Vector2) -> Vector2:
	pos.x = floor(pos.x / GRID_SIZE) * GRID_SIZE
	pos.y = floor(pos.y / GRID_SIZE) * GRID_SIZE
	return pos

var cur_round: int = 0

var _order: Array = []
var _history: Array = []

var AdvanceRoundCommand = load("res://Stage/Commands/Composite/advance_round.gd")


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


func _connect_with_unit(unit: Unit) -> void:
	connect("unit_hovered", unit, "_on_Stage_unit_hovered")
	#connect("unit_clicked", unit, "_on_Stage_unit_clicked")
	#connect("terrain_hovered", unit, "_on_Stage_terrain_hovered")


func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("ui_accept")):
		_history.append(AdvanceRoundCommand.new(self))
		_history.back().execute()

	if (len(_history) > 0 and Input.is_action_just_pressed("ui_cancel")):
		_history.pop_back().undo()

	$UI.visible = cur_round > 0
	$UI.update_order(self)


func get_all_units() -> Array:
	var ret: Array = []
	ret += $Units/Ally.get_children()
	ret += $Units/Enemy.get_children()
	ret += $Units/Neutral.get_children()
	return ret


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
