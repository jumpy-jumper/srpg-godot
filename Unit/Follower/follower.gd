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
	if waiting_for_facing:
		face_cursor()
	if Input.is_action_just_released("mouse_confirm") and Game.confirm_facing_on_release:
		waiting_for_facing = false


	if (Input.is_action_just_pressed("retreat")):
		if (stage.get_node("Cursor").position == position):
			die()


var waiting_for_facing_flag = false # avoids confirming facing the same frame the unit is deployed


func _on_Cursor_confirm_issued(pos):
	if waiting_for_facing and not waiting_for_facing_flag:
		waiting_for_facing_flag = true
	elif waiting_for_facing and waiting_for_facing_flag:
		waiting_for_facing_flag = false
		waiting_for_facing = false
	elif pos == position:
		for skill in $Skills.get_children():
			if skill.is_available():
				skill.activate()
			emit_signal("acted", self)


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
	cooldown = max(0, cooldown - 1)
	waiting_for_facing = false


func update_range():
	.update_range()
	var block_range = get_stat("block_range", base_block_range)


export var base_cooldown = 32

var cooldown = 0

func die():
	.die()
	facing = Facing.RIGHT
	waiting_for_facing = false
	for skill in $Skills.get_children():
		skill.initialize()
	if summoner:
		summoner.recover_faith(ceil(get_stat("cost", base_cost) / 2))
	for enemy in blocked:
		enemy.blocker = null
	cooldown = get_stat("cooldown", base_cooldown)


func _on_Cursor_hovered(pos):
	._on_Cursor_hovered(pos)
	$Ranges.visible = $Ranges.visible or waiting_for_facing


###############################################################################
#        Facing logic                                                         #
###############################################################################


enum Facing {RIGHT = 0, DOWN = 90, LEFT = 180, UP = 270}
export(Facing) var facing = Facing.RIGHT


var waiting_for_facing = false


func face_cursor():
	var cursor_pos = stage.get_node("Cursor").position
	var relative_pos = cursor_pos - position
	var theta = fposmod(rad2deg(atan2(relative_pos.y, relative_pos.x)), 360)
	
	if fmod((theta - 45), 90) != 0:
		facing = int(ceil((theta - 45) / 90) * 90)

###############################################################################
#        Blocking logic                                                       #
###############################################################################


export(Array, Vector2) var base_block_range = [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(0, -1)]
export var base_block_count = 2


var blocked = []


func block_enemies():
	var block_range = get_stat("block_range", base_block_range)
	var block_count = get_stat("block_count", base_block_count)
	
	var blockable_enemies_in_range = get_units_in_range_of_type(block_range, UnitType.ENEMY)
	
	for enemy in blockable_enemies_in_range:
		if enemy.blocker != null:
			blockable_enemies_in_range.erase(enemy)
	
	while len(blocked) < block_count and len(blockable_enemies_in_range) > 0:
		var enemy = blockable_enemies_in_range.pop_front()
		blocked.append(enemy)
		enemy.blocker = self


func clear_block():
	for enemy in blocked:
		enemy.blocker = null
	blocked.clear()
