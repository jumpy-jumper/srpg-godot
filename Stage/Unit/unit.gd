class_name Unit
extends Node2D


signal done()


class State:
	var pos
	var type
	var health
	var ini_base
	var ini_bonus
	var greenlit

enum UnitType { ALLY, ENEMY, NEUTRAL }
enum HealthLevels { HEALTHY, WOUNDED, CRIPPLED, UNCONSCIOUS }
enum CombatStats { STR, END, AGI, INT, PER, FOR }

export(String) var unit_name = ""
export(HealthLevels) var health = HealthLevels.HEALTHY
export(Dictionary) var stats = {
	CombatStats.STR : 0,
	CombatStats.END : 0,
	CombatStats.AGI : 0,
	CombatStats.INT : 0,
	CombatStats.PER : 0,
	CombatStats.FOR : 0,
}

var type = UnitType.ENEMY
export(int) var ini_base = 0
var ini_bonus = 1.0
var stage = null
var terrain = null
var greenlit = false # whether the unit is allowed to issue commands
export(Resource) var weapon = null


func _process(_delta):
	terrain = stage.get_terrain_at(position)
	ini_bonus = terrain.ini_bonus
	$"Sprite".animation = "blue_idle" if type == UnitType.ALLY else "red_idle"
	$UI.update_ui(self)


func get_ini():
	return int(ini_base * ini_bonus)


func get_state():
	var ret = State.new()
	ret.pos = position
	ret.type = type
	ret.health = health
	ret.ini_base = ini_base
	ret.ini_bonus = ini_bonus
	ret.greenlit = greenlit
	return ret


func load_state(state):
	position = state.pos
	type = state.type
	health = state.health
	ini_base = state.ini_base
	ini_bonus = state.ini_bonus
	greenlit = state.greenlit


func _on_Stage_round_started(cur_round):
	ini_base = stats[CombatStats.FOR]


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
			fight(unit)
		emit_signal("done")


class CombatResults:
	enum Type { CLASH, WOUND, CRITICAL, LETHAL }
	var type
	var attacker
	var defender
	var attacker_ini
	var defender_ini
	var wound_cond
	var crit_cond
	var lethal_cond

	func _print():
		print("Type: ", Type.keys()[type])
		print("Final Attacker INI: ", attacker_ini)
		print("Final Defender INI: ", defender_ini)
		print("INI to Wound: ", wound_cond)
		print("INI to Crit: ", crit_cond)
		print("INI to Lethal: ", lethal_cond)

	func _init(a, d):
		self.attacker = a
		self.defender = d

		var atk = 0
		var def = 0
		if attacker.weapon:
			atk = a.weapon.might
			def = d.stats[a.weapon.stat]

		wound_cond = def - atk
		crit_cond = (def * 2) - atk
		lethal_cond = (def * 3) - atk

		if a.get_ini() >= d.get_ini() * 2 and a.get_ini() >= wound_cond:
			if a.get_ini() >= lethal_cond:
				type = Type.LETHAL
			elif a.get_ini() >= crit_cond:
				type = Type.CRITICAL
			else:
				type = Type.WOUND
		else:
			type = Type.CLASH

		attacker_ini = a.get_ini()
		defender_ini = 0

		if type == Type.CLASH:
			defender_ini = d.get_ini()
			var a_atk = max(a.stats[a.weapon.stat], 0)
			var d_atk = max(d.stats[d.weapon.stat], 0)
			if a_atk == 0 and d_atk == 0:
				attacker_ini = 0
				defender_ini = 0
			else:
				var a_turn = true
				while attacker_ini > 0 and defender_ini > 0:
					if a_turn:
						defender_ini -= a_atk
					else:
						attacker_ini -= d_atk
					a_turn = !a_turn

		attacker_ini -= a.get_ini() - a.ini_base
		defender_ini -= d.get_ini() - d.ini_base


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
			unit.take_damage()
			unit.take_damage()
		CombatResults.Type.LETHAL:
			unit.take_damage()
			unit.take_damage()
			unit.take_damage()


func take_damage():
	match health:
		HealthLevels.HEALTHY:
			health = HealthLevels.WOUNDED
		HealthLevels.WOUNDED:
			health = HealthLevels.CRIPPLED
		HealthLevels.CRIPPLED:
			health = HealthLevels.UNCONSCIOUS
