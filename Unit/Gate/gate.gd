class_name Gate
extends Unit


export (Dictionary) var enemies = {}


var enemies_cache = {}


func get_type_of_self():
	return UnitType.GATE


func tick():
	.tick()
	if alive:
		$Blocked.visible = false
		if enemies.has(stage.cur_tick):
			var enemy = enemies_cache[stage.cur_tick]
			
			var path = stage.get_path_to_target(position, \
				stage.summoners_cache[0].position, enemy.traversable)
						
			if stage.get_unit_at(path[1]) == null:
				enemy.alive = true
				enemy.position = path[1]
				enemy.base_level = get_stat("level", base_level)
				enemy.heal_to_full()
			else:
				$Blocked.visible = true
					
			# Die if there are no more enemies to spawn
			for tick in enemies.keys():
				if tick > stage.cur_tick:
					return
			die()
	
	
func _process(_delta):
	if stage.get_node("Cursor").position == position or Input.is_action_pressed("show_gate_paths"):
		$"Path Indicator".update_path(stage.get_path_to_target(position, \
			stage.summoners_cache[0].position, enemies_cache.values()[0].traversable))
		$"Path Indicator".visible = true
	else:
		$"Path Indicator".visible = false
