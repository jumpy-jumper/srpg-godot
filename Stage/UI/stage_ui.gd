extends CanvasLayer


func _ready() -> void:
	$"Unit UI".visible = false
	$"Terrain UI".visible = false


func update_order(stage: Stage) -> void:
	$"Order UI/Round Counter".text = str(stage.cur_round)
	var panels : Array = $"Order UI/Unit Panels".get_children()
	for i in range (len(panels)):
		panels[i].cur_unit = stage._order[i] if i < len(stage._order) else null
		panels[i].current = panels[i].cur_unit == stage.cur_unit


func _on_Stage_unit_hovered(unit: Unit) -> void:
	if unit:
		$"Unit UI".visible = true
		$"Unit UI/Name".text = unit.unit_name
		$"Unit UI/Initiative".text = str(unit.ini_base) + " + " + str(unit.get_ini() - unit.ini_base)
		$"Unit UI/Health".text = str(Unit.HealthLevels.keys()[unit.health])
	else:
		$"Unit UI".visible = false


func _on_Stage_terrain_hovered(terrain) -> void:
	if terrain:
		$"Terrain UI".visible = true
		$"Terrain UI/Name".text = terrain.terrain_name
		$"Terrain UI/Initiative Bonus".text = "INI *" + str(terrain.ini_multiplier)

		$"Terrain UI/Stat Bonus".text = Unit.CombatStats.keys()[terrain.stat]
		$"Terrain UI/Stat Bonus".text += " *" + str(terrain.stat_multiplier)
	else:
		$"Terrain UI".visible = false
