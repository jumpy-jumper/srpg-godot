class_name Follower
extends Unit


export(Texture) var portrait = preload("res://Unit/Follower/Dieck/dieck_portrait.png")
export(Vector2) var mugshot_top_left = Vector2.ZERO

export(Array) var deployable_terrain = null
export var base_cost = 9

var summoner = null


func get_type_of_self():
	return UnitType.FOLLOWER


func get_type_of_enemy():
	return UnitType.ENEMY


###############################################################################
#        Main logic                                                           #
###############################################################################

func _process(_delta):
	if (Input.is_action_just_pressed("debug_change_facing")):
		if (stage.get_node("Cursor").position == position):
			facing = int(facing + 90) % 360


func _on_Cursor_confirm_issued(pos):
	._on_Cursor_confirm_issued(pos)
	if stage.selected_unit == self and stage.get_unit_at(pos) == null:
		position = pos
		stage.deselect_unit()


func _on_Cursor_cancel_issued(pos):
	._on_Cursor_cancel_issued(pos)
	if stage.selected_unit == null and stage.get_unit_at(pos) == self:
		die()
		emit_signal("acted", self)
	elif stage.selected_unit == self:
		stage.deselect_unit()


func get_stat(stat_name, base_value):
	var ret = .get_stat(stat_name, base_value)
	if stat_name == "skill_range" or stat_name == "block_range":
		var rotated = []
		for pos in ret:
			rotated.append(pos.rotated(deg2rad(facing)).round())
		return rotated
	return ret


func tick():
	.tick()
	update_block()


func update_range():
	.update_range()
	var block_range = get_stat("block_range", base_block_range)
	$"Ranges/Block Range".update_range(block_range, stage.get_cell_size())


func die():
	.die()
	facing = Facing.RIGHT
	for skill in $Skills.get_children():
		skill.initialize()
	if summoner:
		summoner.recover_faith(ceil(get_stat("cost", base_cost) / 2))
	for enemy in blocked:
		enemy.blocker = null


###############################################################################
#        Facing logic                                                         #
###############################################################################


enum Facing {RIGHT = 0, DOWN = 90, LEFT = 180, UP = 270}
export(Facing) var facing = Facing.RIGHT


###############################################################################
#        Blocking logic                                                       #
###############################################################################


export(Array, Vector2) var base_block_range = [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(0, -1)]
export var base_block_count = 2


var blocked = []


func update_block():
	var block_range = get_stat("block_range", base_block_range)
	var block_count = get_stat("block_count", base_block_count)
	
	var blockable_enemies_in_range = get_units_in_range_of_type(block_range, UnitType.ENEMY)
	
	for enemy in blockable_enemies_in_range:
		if enemy in blocked or enemy.blocker != null:
			blockable_enemies_in_range.erase(enemy)
	
	
	while len(blocked) < block_count and len(blockable_enemies_in_range) > 0:
		var enemy = blockable_enemies_in_range.pop_front()
		blocked.append(enemy)
		enemy.blocker = self
