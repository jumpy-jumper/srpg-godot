class_name Unit
extends Node2D

signal done(unit)

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
var _ini: int = 0
export(int) var ini_base: int = 0
var ini_bonus: int = 0
var greenlit: bool = false # whether the unit is allowed to issue commands


func _enter_tree() -> void:
	pass


func _process(delta: float) -> void:
	$"Sprite".animation = "blue_idle" if type == UnitType.ALLY else "red_idle"
	$UI.update_ui(self)
	_ini = ini_base + ini_bonus


func _on_Stage_round_started() -> void:
	ini_base = stats[CombatStats.FOR]	# STATE CHANGED
	ini_bonus = 0	# STATE CHANGED
	_ini = ini_base + ini_bonus	# STATE CHANGED
