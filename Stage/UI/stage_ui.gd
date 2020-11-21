extends CanvasLayer


var visible = true


func _ready():
	$"Unit UI".visible = false
	$"Terrain UI".visible = false

func _process(_delta):
	if not visible:
		$"Order UI".visible = false
		$"Unit UI".visible = false
		$"Terrain UI".visible = false

func update_order(stage):
	if not visible:
		return
	$"Order UI".visible = true
	$"Order UI/Round Counter".text = str(stage.cur_round)
	var panels = $"Order UI/Unit Panels".get_children()
	for i in range (len(panels)):
		if i < len(stage.order):
			panels[i].cur_unit = stage.order[i]
			panels[i].current = panels[i].cur_unit.greenlit
		else:
			panels[i].cur_unit = null
			panels[i].current = false


func _on_Stage_unit_hovered(unit):
	if not visible:
		return
	if unit:
		$"Unit UI".visible = true
		$"Unit UI/Name".text = unit.unit_name
		$"Unit UI/Initiative".text = str(unit.ini_base) + " + " + str(unit.get_ini() - unit.ini_base)
		$"Unit UI/Health".text = str(Unit.HealthLevels.keys()[unit.health])
	else:
		$"Unit UI".visible = false


func _on_Stage_terrain_hovered(terrain):
	if not visible:
		return
	if terrain:
		$"Terrain UI".visible = true
		$"Terrain UI/Name".text = terrain.terrain_name
		$"Terrain UI/Initiative Bonus".text = "INI *" + str(terrain.ini_multiplier)
		$"Terrain UI/Movement Cost".text = "MOV " + ("+" if terrain.movement_cost >= 0 else "-")
		$"Terrain UI/Movement Cost".text += str(abs(terrain.movement_cost))
	else:
		$"Terrain UI".visible = false
