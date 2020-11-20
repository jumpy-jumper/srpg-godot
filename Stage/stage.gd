class_name Stage
extends Node

signal unit_hovered(unit)
signal unit_selected(unit)
signal terrain_hovered(terrain)

const GRID_SIZE: int = 64

var cur_unit: Unit = null
var cur_round: int = 0

var _order: Array = []

onready var _cursor = $Player/Cursor
onready var _units = $Units
onready var _ally_units = $Units/Ally
onready var _enemy_units = $Units/Enemy
onready var _neutral_units = $Units/Neutral
onready var _terrain = $Terrain
onready var _unit_panels : Node = $"UI/Order UI/Unit Panels"
onready var _round_counter : Label = $"UI/Order UI/Round Counter"


func _ready() -> void:
	$"UI/Unit UI".visible = false
	$"UI/Terrain UI".visible = false


func _process(_delta: float) -> void:
	if not cur_unit:
		_start_round()
		cur_unit.turn_start()
		cur_unit.on_selected()
	elif not cur_unit.acting:	# unit finished turn
		cur_unit.on_deselected()
		_check_events()
		_next_unit()
		cur_unit.turn_start()
		cur_unit.on_selected()

	_round_counter.text = str(cur_round)
	var panels : Array = _unit_panels.get_children()
	for i in range (len(panels)):
		panels[i].cur_unit = _order[i] if i < len(_order) else null
		panels[i].current = panels[i].cur_unit == cur_unit


static func POSITION_IN_GRID(pos: Vector2) -> Vector2:
	pos.x = floor(pos.x / GRID_SIZE) * GRID_SIZE
	pos.y = floor(pos.y / GRID_SIZE) * GRID_SIZE
	return pos


func _get_unit_at(pos: Vector2) -> Unit:
	for cat in _units.get_children():
		for u in cat.get_children():
			if u.position == pos:
				return u
	return null


func _get_all_units(offset: Vector2 = Vector2()) -> Dictionary:
	var all = []
	for cat in _units.get_children():
		for u in cat.get_children():
			all.append(u)

	var ret = {}
	for u in all:
		var pos = (u.position - offset) / GRID_SIZE
		if ret.has(pos):
			ret[pos].append(u)
		else:
			ret[pos] = [u]
	return ret


func _get_terrain_at(pos: Vector2) -> Terrain:
	for t in _terrain.get_children():
		if t.position == pos:
			return t
	return null


func _get_all_terrain(offset: Vector2 = Vector2()) -> Dictionary:
	var all = []
	for t in _terrain.get_children():
			all.append(t)

	var ret = {}
	for t in all:
		var pos = (t.position - offset) / GRID_SIZE
		if ret.has(pos):
			ret[pos].append(t)
		else:
			ret[pos] = [t]
	return ret


func _order_criteria(a, b) -> bool:
	if a.initiative > b.initiative:
		return true
	return false


func _start_round() -> void:
	cur_round += 1
	print("Round ", cur_round, " start.")
	_order = []
	for cat in _units.get_children():
		for u in cat.get_children():
			if u.health != Unit.HealthLevels.UNCONSCIOUS:
				u.base_initiative = u.stats[Unit.CombatStats.FOR]
				u.bonus_initiative = (_get_terrain_at(u.position).ini_multiplier - 1) * u.base_initiative
				u.initiative = u.base_initiative + u.bonus_initiative
				_order.append(u)
	_order.sort_custom(self, "_order_criteria")
	cur_unit = _order[0]


func _end_round() -> void:
	print("Round ", cur_round, " end.")


func _check_events() -> void:
	pass


func _next_unit() -> void:
	for i in range (len(_order)):
		if _order[i] == cur_unit:
			if i == len(_order) - 1:
				_end_round()
				_start_round()
			else:
				cur_unit = _order[i + 1]
			break


func _on_Cursor_position_updated(pos: Vector2) -> void:
	var unit: Unit = _get_unit_at(pos)
	var terrain: Terrain = _get_terrain_at(pos)

	emit_signal("unit_hovered", unit)
	emit_signal("terrain_hovered", terrain)

	if unit:
		$"UI/Unit UI".visible = true
		$"UI/Unit UI/Name".text = unit.unit_name
		$"UI/Unit UI/Initiative".text = str(unit.base_initiative) + " + " + str(unit.bonus_initiative)
		$"UI/Unit UI/Health".text = str(Unit.HealthLevels.keys()[unit.health])
	else:
		$"UI/Unit UI".visible = false

	if terrain:
		$"UI/Terrain UI".visible = true
		$"UI/Terrain UI/Name".text = terrain.terrain_name
		$"UI/Terrain UI/Initiative Bonus".text = "INI *" + str(terrain.ini_multiplier)

		$"UI/Terrain UI/Stat Bonus".text = Unit.CombatStats.keys()[terrain.stat]
		$"UI/Terrain UI/Stat Bonus".text += " *" + str(terrain.stat_multiplier)
	else:
		$"UI/Terrain UI".visible = false


func _on_Cursor_position_clicked(pos: Vector2) -> void:
	emit_signal("unit_selected", _get_unit_at(pos))
