extends Control


var cur_unit: Unit = null
var cur_terrain: Terrain = null

onready var _unit_control: Control = $"Player HUD/Unit"
onready var _unit_panel_name: Label = $"Player HUD/Unit/Unit Name"
onready var _initiative: Label = $"Player HUD/Unit/Initiative Value"
onready var _health: Label = $"Player HUD/Unit/Health Label"
onready var _terrain_control: Control = $"Player HUD/Terrain"
onready var _terrain_panel_name: Label = $"Player HUD/Terrain/Unit Name"
onready var _ini_bonus: Label = $"Player HUD/Terrain/Initiative Value"
onready var _stat_bonus: Label = $"Player HUD/Terrain/Health Label"


func _ready() -> void:
	_unit_control.visible = false
	_terrain_control.visible = false


func _on_Stage_unit_hovered(unit: Unit) -> void:
	if unit:
		_unit_control.visible = true
		_unit_panel_name.text = unit.unit_name
		_initiative.text = str(unit.base_initiative) + " + " + str(unit.bonus_initiative)
		_health.text = str(Unit.HealthLevels.keys()[unit.health])
	else:
		_unit_control.visible = false


func _on_Stage_terrain_hovered(terrain: Terrain) -> void:
	if terrain:
		_terrain_control.visible = true
		_terrain_panel_name.text = terrain.terrain_name
		_ini_bonus.text = "INI *" + str(terrain.ini_multiplier)

		_stat_bonus.text = Unit.CombatStats.keys()[terrain.stat]
		_stat_bonus.text += " *" + str(terrain.stat_multiplier)
	else:
		_terrain_control.visible = false
