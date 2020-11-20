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
			u.connect("done", self, "_on_Unit_done")
			connect("unit_greenlit", u, "_on_Stage_unit_greenlit")
			connect("unit_clicked", u, "_on_Stage_unit_clicked")
			match cat.name:
				"Ally":
					u.type = Unit.UnitType.ALLY
				"Enemy":
					u.type = Unit.UnitType.ENEMY
				"Neutral":
					u.type = Unit.UnitType.NEUTRAL

	_start_round()
	emit_signal("unit_greenlit", cur_unit)

	$"UI/Unit UI".visible = false
	$"UI/Terrain UI".visible = false


func _process(_delta: float) -> void:
	# Update order UI
	$"UI/Order UI/Round Counter".text = str(cur_round)
	var panels : Array = $"UI/Order UI/Unit Panels".get_children()
	for i in range (len(panels)):
		panels[i].cur_unit = _order[i] if i < len(_order) else null
		panels[i].current = panels[i].cur_unit == cur_unit


func _order_criteria(a, b) -> bool:
	if a.ini > b.ini:
		return true
	return false


func _start_round() -> void:
	cur_round += 1
	print("Round ", cur_round, " start.")
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


func _get_all_units(offset: Vector2 = Vector2()) -> Dictionary:
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


func _get_terrain_at(pos: Vector2) -> Terrain:
	for t in $Terrain.get_children():
		if t.position == pos:
			return t
	return null


func _get_all_terrain(offset: Vector2 = Vector2()) -> Dictionary:
	var all = []
	for t in $Terrain.get_children():
			all.append(t)

	var ret = {}
	for t in all:
		var pos = (t.position - offset) / GRID_SIZE
		if ret.has(pos):
			ret[pos].append(t)
		else:
			ret[pos] = [t]
	return ret


func _on_Cursor_position_updated(pos: Vector2) -> void:
	var unit: Unit = _get_unit_at(pos)
	var terrain: Terrain = _get_terrain_at(pos)

	emit_signal("unit_hovered", unit)
	emit_signal("terrain_hovered", terrain)

	# Update UI
	if unit:
		$"UI/Unit UI".visible = true
		$"UI/Unit UI/Name".text = unit.unit_name
		$"UI/Unit UI/Initiative".text = str(unit.ini_base) + " + " + str(unit.ini_bonus)
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
	emit_signal("unit_clicked", _get_unit_at(pos))


func _on_Unit_done() -> void:
	_next_unit()
	emit_signal("unit_greenlit", cur_unit)

