class_name PlayerHUD
extends CanvasLayer


var cur_unit: Unit = null
var cur_terrain: Terrain = null

onready var _unit_control: Control = $Unit
onready var _unit_panel_name: Label = $"Unit/Unit Name"
onready var _initiative: Label = $"Unit/Initiative Value"
onready var _health: Label = $"Unit/Health Label"
onready var _terrain_control: Control = $Terrain
onready var _terrain_panel_name: Label = $"Terrain/Unit Name"
onready var _ini_bonus: Label = $"Terrain/Initiative Value"
onready var _stat_bonus: Label = $"Terrain/Health Label"


func _process(_delta) -> void:
	if cur_unit:
		_unit_control.visible = true
		_unit_panel_name.text = cur_unit.unit_name
		_initiative.text = str(cur_unit.base_initiative) + " + " + str(cur_unit.bonus_initiative)
		_health.text = str(Unit.HealthLevels.keys()[cur_unit.health])
	else:
		_unit_control.visible = false

	if cur_terrain:
		_terrain_control.visible = true
		_terrain_panel_name.text = cur_terrain.terrain_name
		_ini_bonus.text = "INI *" + str(cur_terrain.ini_multiplier)

		_stat_bonus.text = Unit.CombatStats.keys()[cur_terrain.stat]
		_stat_bonus.text += " *" + str(cur_terrain.stat_multiplier)
	else:
		_terrain_control.visible = false
