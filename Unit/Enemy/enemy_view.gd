extends UnitView


func _process(_delta):	
	visible = unit.alive
	if not $DeathTweener.is_active():
		modulate.a = 1.0 if unit.alive else 0
	elif unit.alive:
		$DeathTweener.stop_all()
		modulate.a = 1.0
		
	$"Blocked".visible = unit.blocker != null


onready var base_path_alpha = $"Path Indicator".default_color.a


func _on_Unit_hovered():
	._on_Unit_hovered()		
	$"Path Indicator".points = PoolVector2Array(unit.path)
	$"Path Indicator".visible = true
	$"Path Indicator".default_color.a = (1 - pow(base_path_alpha, 2))


func _on_Unit_unhovered():
	._on_Unit_unhovered()
	$"Path Indicator".visible = unit.marked	
	$"Path Indicator".default_color.a = base_path_alpha
