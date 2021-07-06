class_name Gate
extends Unit


export (Dictionary) var enemies = {}


func get_type_of_self():
	return UnitType.GATE


func tick():
	.tick()
	if enemies.has(stage.cur_tick):
		var enemy = enemies[stage.cur_tick]
		var adjacent = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
		for tile in adjacent:
			tile = (tile * stage.get_cell_size()) + position
			if stage.get_terrain_at(tile) in enemy.traversable \
				and stage.get_unit_at(tile) == null:
					enemy.alive = true
					enemy.position = tile
					enemy.base_level = get_stat("level", base_level)
					enemy.heal_to_full()
					break
				
		# Die if there are no more enemies to spawn
		for tick in enemies.keys():
			if tick > stage.cur_tick:
				return
		die()
