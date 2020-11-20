class_name Stage
extends Node


const GRID_SIZE: int = 64

var cur_unit: Unit = null
var cur_round: int = 0

var order: Array = []

onready var _cursor = $Player/Cursor
onready var _units = $Units
onready var _ally_units = $Units/Ally
onready var _enemy_units = $Units/Enemy
onready var _neutral_units = $Units/Neutral
onready var _terrain = $Terrain


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

func get_unit_at(pos: Vector2) -> Unit:
	for cat in _units.get_children():
		for u in cat.get_children():
			if u.position == pos:
				return u
	return null


func get_all_units(offset: Vector2 = Vector2()) -> Dictionary:
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


func get_terrain_at(pos: Vector2) -> Terrain:
	for t in _terrain.get_children():
		if t.position == pos:
			return t
	return null


func get_all_terrain(offset: Vector2 = Vector2()) -> Dictionary:
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
	order = []
	for cat in _units.get_children():
		for u in cat.get_children():
			if u.health != Unit.HealthLevels.UNCONSCIOUS:
				u.base_initiative = u.stats[Unit.CombatStats.FOR]
				u.bonus_initiative = (get_terrain_at(u.position).ini_multiplier - 1) * u.base_initiative
				u.initiative = u.base_initiative + u.bonus_initiative
				order.append(u)
	order.sort_custom(self, "_order_criteria")
	cur_unit = order[0]


func _end_round() -> void:
	print("Round ", cur_round, " end.")


func _check_events() -> void:
	pass


func _next_unit() -> void:
	for i in range (len(order)):
		if order[i] == cur_unit:
			if i == len(order) - 1:
				_end_round()
				_start_round()
			else:
				cur_unit = order[i + 1]
			break
