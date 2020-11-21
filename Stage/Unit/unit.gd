class_name Unit
extends Node2D


signal done()


class State:
	var pos
	var type
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
	ret.ini_base = ini_base
	ret.ini_bonus = ini_bonus
	ret.greenlit = greenlit
	return ret


func load_state(state):
	position = state.pos
	type = state.type
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
		yield(get_tree(), "idle_frame")
		emit_signal("done")
