extends CanvasLayer


var visible = true


func _ready():
	$"Unit UI".visible = false
	$"Terrain UI".visible = false

func _process(_delta):
	if not visible:
		$"Unit UI".visible = false
		$"Terrain UI".visible = false


func _on_Stage_unit_hovered(unit):
	if not visible:
		return
	if unit:
		$"Unit UI".visible = true
		$"Unit UI/Name".text = unit.unit_name
		$"Unit UI/Initiative".text = str(unit.ini)
		$"Unit UI/Health".text = str(unit.hp)
	else:
		$"Unit UI".visible = false


func _on_Stage_terrain_hovered(terrain):
	if not visible:
		return
	if terrain:
		$"Terrain UI".visible = true
		$"Terrain UI/Name".text = terrain.terrain_name
		$"Terrain UI/Initiative Bonus".text = "INI *" + str(terrain.ini_bonus)
		$"Terrain UI/Movement Cost".text = "MOV " + ("+" if terrain.cost >= 0 else "-")
		$"Terrain UI/Movement Cost".text += str(abs(terrain.cost))
	else:
		$"Terrain UI".visible = false
