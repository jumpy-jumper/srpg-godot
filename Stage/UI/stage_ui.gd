extends CanvasLayer


var visible: bool = true


func _ready() -> void:
	$"Unit UI".visible = false
	$"Terrain UI".visible = false

func _process(delta: float) -> void:
	if not visible:
		$"Order UI".visible = false
		$"Unit UI".visible = false
		$"Terrain UI".visible = false

func update_order(stage: Stage) -> void:
	if not visible:
		return
	$"Order UI".visible = true
	$"Order UI/Round Counter".text = str(stage.cur_round)
	var panels : Array = $"Order UI/Unit Panels".get_children()
	for i in range (len(panels)):
		if i < len(stage._order):
			panels[i].cur_unit = stage._order[i]
			panels[i].current = panels[i].cur_unit.greenlit
		else:
			panels[i].cur_unit = null
			panels[i].current = false


func _on_Stage_unit_hovered(unit: Unit) -> void:
	if not visible:
		return
	if unit:
		$"Unit UI".visible = true
		$"Unit UI/Name".text = unit.unit_name
		$"Unit UI/Initiative".text = str(unit.ini_base)
		$"Unit UI/Initiative".text += " + " + str(unit.get_ini() - unit.ini_base)
		$"Unit UI/Health".text = str(Unit.HealthLevels.keys()[unit.health])
	else:
		$"Unit UI".visible = false


func _on_Stage_terrain_hovered(terrain) -> void:
	if not visible:
		return
	if terrain:
		$"Terrain UI".visible = true
		$"Terrain UI/Name".text = terrain.terrain_name
		$"Terrain UI/Initiative Bonus".text = "INI *" + str(terrain.ini_multiplier)

		$"Terrain UI/Stat Bonus".text = Unit.CombatStats.keys()[terrain.stat]
		$"Terrain UI/Stat Bonus".text += " *" + str(terrain.stat_multiplier)
	else:
		$"Terrain UI".visible = false
