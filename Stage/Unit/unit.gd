class_name Unit
extends Node2D

signal done()

enum UnitType { ALLY, ENEMY, NEUTRAL }
enum HealthLevels { HEALTHY, WOUNDED, CRIPPLED, UNCONSCIOUS }
enum CombatStats { STR, END, AGI, INT, PER, FOR }

export(String) var unit_name: String = ""
export(HealthLevels) var health: int = HealthLevels.HEALTHY
export(Dictionary) var stats: Dictionary = {
	CombatStats.STR : 0,
	CombatStats.END : 0,
	CombatStats.AGI : 0,
	CombatStats.INT : 0,
	CombatStats.PER : 0,
	CombatStats.FOR : 0,
}

var type: int = UnitType.ENEMY
export(int) var ini_base: int = 0
var ini_bonus: float = 1
var greenlit: bool = false # whether the unit is allowed to issue commands


func _enter_tree() -> void:
	pass


func _process(delta: float) -> void:
	$"Sprite".animation = "blue_idle" if type == UnitType.ALLY else "red_idle"
	$UI.update_ui(self)


func get_ini() -> int:
	return int(ini_base * ini_bonus)


class State:
	var pos: Vector2
	var type: int
	var ini_base: int
	var ini_bonus: float
	var greenlit: bool


func get_state() -> State:
	var ret: State = State.new()
	ret.pos = position
	ret.type = type
	ret.ini_base = ini_base
	ret.ini_bonus = ini_bonus
	ret.greenlit = greenlit
	return ret


func load_state(state: State) -> void:
	position = state.pos
	type = state.type
	ini_base = state.ini_base
	ini_bonus = state.ini_bonus
	greenlit = state.greenlit


func _on_Stage_round_started(cur_round: int) -> void:
	ini_base = stats[CombatStats.FOR]
	ini_bonus = 2 if cur_round % 2 == 1 else 1


func _on_Stage_unit_greenlit(unit: Unit) -> void:
	greenlit = unit == self


func _on_Stage_unit_clicked(unit: Unit) -> void:
	if greenlit:
		emit_signal("done")
