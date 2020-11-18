extends Node2D

class_name Unit

# There must be a stage
var stage
func _ready():
	stage = get_tree().root.get_node("Stage")

# Stats
enum unit_type { ally, enemy, neutral }
export(unit_type) var type = unit_type.enemy

enum health_levels { healthy, wounded, crippled, unconscious }
export(health_levels) var health = health_levels.healthy
export(int) var initiative = 0

enum combat_stats { strength, endurance, agility, intelligence, perception, foresight }
export var stats = { combat_stats.strength : 0, 
	combat_stats.endurance : 0,
	combat_stats.agility : 0,
	combat_stats.intelligence : 0,
	combat_stats.perception : 0,
	combat_stats.foresight : 0
}

export(int) var movement = 0

# Equipment

# Self interaction methods

func take_withering(value):
	initiative -= value
	initiative = max(0, initiative)

func take_lethal(crit = false):
	health += 2 if crit else 1
	health = min(health, 3)

# Unit interaction methods

func fight(other):
	print(name, " fights ", other.name)
	other.take_lethal()

# Calls from the stage or the cursor

var idle = true
func turn_start():
	print(name, "'s turn.")
	if type == unit_type.enemy:
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
	var target = stage.get_unit_at(pos)
	if target and target.type == unit_type.enemy and target.health != health_levels.unconscious:
		fight(target)
		turn_end()
