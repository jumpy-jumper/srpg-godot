extends Node2D

class_name Unit

enum unit_type { ally, enemy, neutral }
export(unit_type) var type = unit_type.enemy

enum health_levels { healthy, wounded, crippled, unconscious }
export(health_levels) var health = health_levels.healthy
var initiative = 0

export(int) var strength = 0
export(int) var endurance = 0
export(int) var agility = 0
export(int) var intelligence = 0
export(int) var perception = 0
export(int) var foresight = 0

var done = false

var acting = false
func act():
	acting = true
	if Input.is_action_just_pressed("ui_accept"):
		print(name, " passes turn.")
		acting = false

func _process(delta):
	if acting:
		act()