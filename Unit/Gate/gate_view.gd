extends UnitView


func _ready():
	$"Path Indicator".visible = true
	$"Path Indicator".modulate = modulate


func _process(_delta):
	if not $DeathTweener.is_active():
		$Sprite.modulate.a = 1.0 if unit.alive else 0
	elif unit.alive:
		$DeathTweener.stop_all()
		$Sprite.modulate.a = 1.0
		
	if $"Path Indicator".visible and not unit.alive:
		$"Path Indicator".visible = false
		for enemy in unit.enemies.values():
			if enemy.alive:
				$"Path Indicator".visible = true
	
	$Blocked.visible = unit.blocked

onready var base_path_alpha = $"Path Indicator".default_color.a


func _on_Unit_hovered():
	._on_Unit_hovered()
	var path = []
	for i in range(len(unit.path)):
		path.append(unit.path[i]-global_position)
	$"Path Indicator".points = PoolVector2Array(path)
	$"Path Indicator".visible = true
	$"Path Indicator".default_color.a = (1 - pow(base_path_alpha, 2))


func _on_Unit_unhovered():
	._on_Unit_unhovered()
	$"Path Indicator".visible = unit.marked	
	$"Path Indicator".default_color.a = base_path_alpha
