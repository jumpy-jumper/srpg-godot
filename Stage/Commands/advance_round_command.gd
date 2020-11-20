class_name AdvanceRoundCommand


var _stage: Stage
var _prev_round: int
var _prev_order: Array
var _prev_greenlit: Unit
var _new_greenlit: Unit
var _prev_ini: Dictionary


func execute(stage: Stage) -> void:
	_stage = stage
	_prev_round = _stage.cur_round
	_prev_order = stage._order
	_prev_greenlit = null
	for u in stage.get_all_units():
		_prev_ini[u] = u.ini_base
		if u.greenlit:
			_prev_greenlit = u
			u.greenlit = false

	if _prev_greenlit == null:
		_new_round(stage, _prev_greenlit)
	else:
		for i in range (len(stage._order)):
			if stage._order[i] == _prev_greenlit:
				if i == len(stage._order) - 1:
					_new_round(stage, _prev_greenlit)
				else:
					pass
					_new_greenlit = stage._order[i + 1]
				break

	_new_greenlit.greenlit = true


func _new_round(stage: Stage, unit: Unit) -> void:
	stage.cur_round += 1
	stage._order = []
	for u in stage.get_all_units():
		u.ini_base = u.stats[Unit.CombatStats.FOR]
		stage._order.append(u)
	stage._order.sort_custom(stage, "_order_criteria")
	_new_greenlit = stage._order[0]
	_new_greenlit.greenlit = true


func undo() -> void:
	_stage.cur_round = _prev_round
	_stage._order = _prev_order
	for u in _stage.get_all_units():
		u.ini_base = _prev_ini[u]
	if _prev_greenlit:
		_prev_greenlit.greenlit = true
	_new_greenlit.greenlit = false
