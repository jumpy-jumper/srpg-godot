class_name Unit
extends Node2D


signal acted(done)
signal done()
signal dead(unit)

enum UnitType { ALLY, ENEMY, NEUTRAL }
enum HealthLevels { HEALTHY, WOUNDED, CRIPPLED }
enum CombatStats { STR, END, AGI, INT, PER, FOR }
enum IniBonusType { HEALTH, TERRAIN, OTHER }

export(String) var unit_name = ""
export(int) var level = 1
export(Resource) var unit_class = null
var type = UnitType.ENEMY
export(Dictionary) var stat_offsets = {
	CombatStats.STR : 0,
	CombatStats.END : 0,
	CombatStats.AGI : 0,
	CombatStats.INT : 0,
	CombatStats.PER : 0,
	CombatStats.FOR : 0,
}

export(HealthLevels) var health = HealthLevels.HEALTHY
export(int) var ini_base = 0
var ini_bonuses = {
	IniBonusType.HEALTH : 1.0,
	IniBonusType.TERRAIN : 1.0,
	IniBonusType.OTHER : 1.0
}

var stage = null
var greenlit = false # whether the unit is allowed to act

export(Resource) var weapon = null


func _process(_delta):
	$"Sprite".animation = "blue_idle" if type == UnitType.ALLY else "red_idle"
	$UI.update_ui(self)


func get_ini_bonus():
	var ret = 1
	for b in ini_bonuses.values():
		ret *= b
	return ret


func get_ini():
	return int(ini_base * get_ini_bonus())


func get_stats():
	var ret = {}
	for s in unit_class.base_stats:
		ret[s] = unit_class.base_stats[s] + floor(unit_class.growths[s] * level) + stat_offsets[s]
	return ret


class State:
	var frames
	var unit_name
	var level
	var unit_class
	var type
	var stat_offsets = {}
	var pos
	var health
	var ini_base
	var ini_bonuses = {}
	var greenlit
	var weapon


func get_state():
	var ret = State.new()
	ret.frames = $Sprite.frames
	ret.unit_name = unit_name
	ret.level = level
	ret.type = type
	ret.unit_class = unit_class
	ret.pos = position
	ret.health = health
	ret.ini_base = ini_base
	for b in ini_bonuses:
		ret.ini_bonuses[b] = ini_bonuses[b]
	ret.greenlit = greenlit
	ret.weapon = weapon
	return ret


func load_state(state):
	$Sprite.frames = state.frames
	unit_name = state.unit_name
	level = state.level
	type = state.type
	unit_class = state.unit_class
	position = state.pos
	health = state.health
	ini_base = state.ini_base
	for b in state.ini_bonuses:
		ini_bonuses[b] = state.ini_bonuses[b]
	self.stage = stage
	greenlit = state.greenlit
	weapon = state.weapon


func fight(unit):
	var results = CombatResults.new(self, unit)
	results._print()
	match results.type:
		CombatResults.Type.CLASH:
			ini_base = results.attacker_ini
			unit.ini_base = results.defender_ini
		CombatResults.Type.WOUND:
			unit.take_damage()
		CombatResults.Type.CRITICAL:
			unit.take_damage(2)
		CombatResults.Type.LETHAL:
			unit.take_damage(3)
	return results


func take_damage(times = 1):
	for i in range (times):
		match health:
			HealthLevels.HEALTHY:
				health = HealthLevels.WOUNDED
			HealthLevels.WOUNDED:
				health = HealthLevels.CRIPPLED
			HealthLevels.CRIPPLED:
				die()
				return


func die():
	emit_signal("dead", self)
	queue_free()


func _on_Stage_round_advanced(cur_round):
	pass


func _on_Stage_round_started(cur_round):
	ini_base = get_stats()[CombatStats.FOR]


func _on_Stage_unit_greenlit(unit):
	greenlit = unit == self


func _on_Stage_unit_hovered(unit):
	pass


func _on_Stage_unit_clicked(unit):
	pass


func _on_Stage_terrain_hovered(unit):
	pass


func _on_Cursor_position_hovered(pos):
	pass


func _on_Cursor_position_clicked(pos):
	if greenlit:
		var unit = stage.get_unit_at(pos)
		if unit:
			if unit == self:
				print_stats()
				emit_signal("acted", true)
			else:
				var prev = unit.get_ini()
				fight(unit)
				if prev <= 0 or unit.get_ini() > 0 or get_ini() <= 0:
					emit_signal("acted", true)
				else:
					emit_signal("acted", false)
		else:
			position = pos
			emit_signal("acted", false)


func print_stats():
	print("Name: ", unit_name)
	print("Class: ", unit_class.name)
	for s in get_stats():
		print(CombatStats.keys()[s], ": ", get_stats()[s])
	print()
