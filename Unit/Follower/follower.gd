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
	$"Sprite/UI".visible = alive
	
	var activatable_skill = null
	for skill in $Skills.get_children():
		if skill.activation == skill.Activation.SP_MANUAL:
			activatable_skill = skill
			break
	$Sprite/Ready.visible = activatable_skill.is_available() if activatable_skill else false
	
	if not $DeathTweener.is_active():
		modulate.a = 0.5 if previewing else (1.0 if alive else 0)
	elif alive:
		$DeathTweener.stop_all()
		modulate.a = 1.0
	
	if waiting_for_facing and Game.mouse_enabled and stage.can_update_facing():
			if Game.mouse_idle == 0:
				face_mouse()
			if Input.is_action_just_released("mouse_confirm") \
				and Game.confirm_facing_on_release \
				and stage.get_clamped_position(get_global_mouse_position()) != position:
					confirm_facing()


func _input(event):
	if event.is_action_pressed("retreat"):
		if alive and (stage.cursor.position == position):
			die()
			stage.append_state()
	elif waiting_for_facing:
		var direction = Game.get_keyboard_input(true)
		if direction.length_squared() > 0:
			if direction == Vector2.RIGHT:
				facing = Facing.RIGHT
			elif direction == Vector2.DOWN:
				facing = Facing.DOWN
			elif direction == Vector2.LEFT:
				facing = Facing.LEFT
			elif direction == Vector2.UP:
				facing = Facing.UP


func can_be_deployed():
	return get_stat("cost", base_cost) <= summoner.faith \
		and not alive and cooldown == 0


func deploy_self(pos):
		alive = true
		global_position = stage.get_clamped_position(pos)
		summoner.faith -= get_stat("cost", base_cost)
		for skill in get_node("Skills").get_children():
			skill.initialize()
			if skill.activation == skill.Activation.DEPLOYMENT \
				or skill.activation == skill.Activation.SP_AUTO and skill.is_available():
					skill.activate()
		display_toasts()
		facing = Facing.RIGHT
		waiting_for_facing = true
		stage.append_state()


func _on_Cursor_confirm_issued(pos):
	if not alive and not stage.is_waiting_for_facing():
		if stage.get_selected_follower() == self and stage.get_unit_at(pos) == null:
			if stage.get_terrain_at(pos) in deployable_terrain \
				and can_be_deployed():
					deploy_self(pos)
	elif alive and waiting_for_facing:
		confirm_facing()
	elif alive:
		if pos == position:
			for skill in $Skills.get_children():
				if skill.is_available():
					skill.activate()


func get_stat(stat_name, base_value):
	var ret = .get_stat(stat_name, base_value)
	if stat_name == "skill_range" or stat_name == "block_range":
		var rotated = []
		for pos in ret:
			rotated.append(pos.rotated(deg2rad(facing)).round())
		return rotated
	return ret


func _on_Stage_tick_ended():
	._on_Stage_tick_ended()
	cooldown = max(0, cooldown - 1)


export var base_cooldown = 32

var cooldown = 0

func die():
	.die()
	waiting_for_facing = false
	for skill in $Skills.get_children():
		skill.initialize()
	if summoner:
		summoner.recover_faith(ceil(get_stat("cost", base_cost) / 2))
	for enemy in blocked:
		enemy.blocker = null
	cooldown = get_stat("cooldown", base_cooldown)


var previewing = false

func _on_Cursor_hovered(pos):
	._on_Cursor_hovered(pos)
	$Ranges.visible = $Ranges.visible or waiting_for_facing
	if not alive \
		and stage.get_selected_follower() == self \
		and stage.get_unit_at(pos) == null \
		and stage.get_terrain_at(pos) in deployable_terrain \
		and summoner.faith >= get_stat("cost", base_cost) \
		and cooldown == 0:
			position = pos
			previewing = true
	else:
		previewing = false


###############################################################################
#        Facing logic                                                         #
###############################################################################


enum Facing {RIGHT = 0, DOWN = 90, LEFT = 180, UP = 270}
export(Facing) var facing = Facing.RIGHT


var waiting_for_facing = false


func face_mouse():
	var relative_pos = get_global_mouse_position() - position - Vector2(stage.get_cell_size(), stage.get_cell_size()) / 2
	var theta = fposmod(rad2deg(atan2(relative_pos.y, relative_pos.x)), 360)
	
	if fmod((theta - 45), 90) != 0:
		facing = int(ceil((theta - 45) / 90) * 90)


func confirm_facing():
	waiting_for_facing = false
	if self in stage.summoned_order:
		stage.summoned_order.erase(self)
	stage.summoned_order.push_back(self)
	stage.replace_last_state() # the last state should be right before confirming facing


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


###############################################################################
#        State                                                                #
###############################################################################


func get_state():
	var ret = .get_state()
	ret["facing"] = facing
	ret["cooldown"] = cooldown
	return ret


func load_state(state):
	.load_state(state)
	facing = state["facing"]
	cooldown = state["cooldown"]
	waiting_for_facing = false
