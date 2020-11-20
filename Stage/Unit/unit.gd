class_name Unit
extends Node2D


enum UnitType { ALLY, ENEMY, NEUTRAL }
enum HealthLevels { HEALTHY, WOUNDED, CRIPPLED, UNCONSCIOUS }
enum CombatStats { STR, END, AGI, INT, PER, FOR }

export(String) var unit_name: String = ""
export(UnitType) var type: int = UnitType.ENEMY
export(HealthLevels) var health: int = HealthLevels.HEALTHY
export(int) var initiative: int = 0
export(int) var base_initiative: int = 0
export(int) var bonus_initiative: int = 0
export(Dictionary) var stats: Dictionary = {
	CombatStats.STR : 0,
	CombatStats.END : 0,
	CombatStats.AGI : 0,
	CombatStats.INT : 0,
	CombatStats.PER : 0,
	CombatStats.FOR : 0,
}

var acting: bool = false
var hovered: bool = false
var selected: bool = false

onready var _stage = $"../../.."


func take_withering(value: int) -> void:
	initiative -= value
	initiative = max(0, initiative)


func take_lethal(crit: bool = false) -> void:
	health += 2 if crit else 1
	health = min(health, 3)


func fight(other: Unit) -> void:
	print(name, " fights ", other.name)
	other.take_lethal()


func turn_start() -> void:
	print(name, "'s turn.")
	acting = true


func turn_end() -> void:
	acting = false


func on_hovered() -> void:
	hovered = true


func on_unhovered() -> void:
	hovered = false


func on_selected() -> void:
	selected = true


func on_deselected() -> void:
	selected = false


func on_click_while_selected(pos: Vector2) -> void:
	if type == UnitType.ALLY:
		var target: Unit = _stage.get_unit_at(pos)
		if target and target.type == UnitType.ENEMY and target.health != HealthLevels.UNCONSCIOUS:
			fight(target)
			turn_end()
	else:
		turn_end()
