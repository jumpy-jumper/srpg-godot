class_name Unit
extends Node2D


enum UnitType { ALLY, ENEMY, NEUTRAL }
enum HealthLevels { HEALTHY, WOUNDED, CRIPPLED, UNCONSCIOUS }
enum CombatStats { STR, END, AGI, INT, PER, FOR }

export(UnitType) var type = UnitType.ENEMY
export(HealthLevels) var health = HealthLevels.HEALTHY
export(int) var initiative = 0
export(Dictionary) var stats = { CombatStats.STR : 0, 
	CombatStats.END : 0,
	CombatStats.AGI : 0,
	CombatStats.INT : 0,
	CombatStats.PER : 0,
	CombatStats.FOR : 0,
}
export(int) var movement = 0

var idle = true

onready var _stage = get_tree().root.get_node("Stage")


func take_withering(value):
	initiative -= value
	initiative = max(0, initiative)


func take_lethal(crit = false):
	health += 2 if crit else 1
	health = min(health, 3)
	

func fight(other):
	print(name, " fights ", other.name)
	other.take_lethal()


func turn_start():
	print(name, "'s turn.")
	if type == UnitType.ENEMY:
		print(name, "passes.")
		turn_end()
	else:
		idle = false


func turn_end():
	idle = true


func on_hovered():
	$Movement.hovered = true
	
	
func on_unhovered():
	$Movement.hovered = false


func on_selected():
	$Movement.selected = true
	
	
func on_deselected():
	$Movement.selected = false
	
	
func on_click_while_selected(pos):
	var target = _stage.get_unit_at(pos)
	if target and target.type == UnitType.ENEMY and target.health != HealthLevels.UNCONSCIOUS:
		fight(target)
		turn_end()
