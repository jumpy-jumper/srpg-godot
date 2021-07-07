class_name Gate
extends Unit


export (Dictionary) var enemies = {}


var enemies_cache = {}


func get_type_of_self():
	return UnitType.GATE


func tick():
	.tick()
	if alive:
		if enemies.has(stage.cur_tick):
			var enemy = enemies_cache[stage.cur_tick]
			
			var path = stage.get_path_to_target(position, \
				stage.summoners_cache[0].position, enemy.traversable)
						
			if stage.get_unit_at(path[1]) == null:
				enemy.alive = true
				enemy.position = path[1]
				enemy.base_level = get_stat("level", base_level)
				enemy.heal_to_full()
					
			# Die if there are no more enemies to spawn
			for tick in enemies.keys():
				if tick > stage.cur_tick:
					return
			die()
