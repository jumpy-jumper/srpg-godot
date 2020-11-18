class_name Stage
extends Node


const GRID_SIZE: int = 64

var cur_unit: Unit = null	
var cur_round: int = 0

var _order: Array = []

onready var _cursor = $Player/Cursor
	

func _process(_delta: float) -> void:
	if not cur_unit:
		_start_round()
		cur_unit.turn_start()
	elif cur_unit.idle:	# unit finished turn
		cur_unit.on_deselected()
		_check_events()
		_next_unit()
		cur_unit.turn_start()
		
	if cur_unit.type == Unit.UnitType.ALLY:
		_cursor.selected = cur_unit
		cur_unit.on_selected()
	else:
		_cursor.selected = null


func get_unit_at(pos: Vector2) -> Unit:
	for cat in $Units.get_children():
		for u in cat.get_children():
			if u.position == pos:
				return u
	return null


func get_all_units(offset: Vector2 = Vector2()) -> Dictionary:
	var all = []
	for cat in $Units.get_children():
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


func _unit_order(a, b) -> bool:
	if a.initiative > b.initiative:
		return true
	return false


func _start_round() -> void:
	cur_round += 1
	print("Round ", cur_round, " start.")
	_order = []
	for cat in $Units.get_children():
		for u in cat.get_children():
			if u.health != Unit.HealthLevels.UNCONSCIOUS:
				u.initiative = u.stats[Unit.CombatStats.FOR]
				_order.append(u)
	_order.sort_custom(self, "_unit_order")		
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
