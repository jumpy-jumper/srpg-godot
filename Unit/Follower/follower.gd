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

var group = []

###############################################################################
#        Main logic                                                           #
###############################################################################

func _ready():
	facing = Facing.values()[wind]

func _process(_delta):
	$"Sprite/UI".visible = alive
	
	var activatable_skill = get_first_activatable_skill()
	$Sprite/Ready.visible = alive and (activatable_skill.is_available() if activatable_skill else false)
	
	if not $DeathTweener.is_active():
	
		modulate.a = 0.5 if previewing else (1.0 if alive else 0)
	elif alive:
		$DeathTweener.stop_all()
		modulate.a = 1.0
	
	if waiting_for_user and stage.can_update_facing():
			if Game.mouse_idle == 0:
				face_mouse()
			if Input.is_action_just_released("mouse_confirm") \
				and Game.confirm_facing_on_release \
				and stage.get_clamped_position(get_global_mouse_position()) != position:
					confirm_facing()


func _input(event):
	if event.is_action_pressed("retreat") \
		or (event.is_action_pressed("mouse_cancel") \
		and Input.is_action_pressed("mouse_confirm")):
			if alive and (stage.cursor.position == position):
				die()
				stage.append_state()
	elif waiting_for_user:
		var direction = InputWatcher.get_keyboard_input(true)
		if direction.length_squared() > 0:
			if direction == Vector2.RIGHT:
				facing = Facing.RIGHT
			elif direction == Vector2.DOWN:
				facing = Facing.DOWN
			elif direction == Vector2.LEFT:
				facing = Facing.LEFT
			elif direction == Vector2.UP:
				facing = Facing.UP


func get_alive_in_group():
	for unit in group:
		if unit.alive:
			return unit
	return null


func can_be_deployed():
	return get_stat("cost") <= summoner.faith \
		and not get_alive_in_group() and cooldown == 0


func deploy_self(pos):
		alive = true
		facing = Facing.values()[wind]
		global_position = stage.get_clamped_position(pos)
		emit_signal("moved", self, position)
		summoner.faith -= get_stat("cost")
		for skill in get_node("Skills").get_children():
			skill.initialize()
			if skill.activation == skill.Activation.DEPLOYMENT \
				or skill.activation == skill.Activation.SP_AUTO and skill.is_available():
					skill.activate()
		display_toasts()
		#waiting_for_user = true
		stage.append_state()
		confirm_facing()


func _on_Cursor_confirm_issued(pos):
	._on_Cursor_confirm_issued(pos)
	if not alive and not stage.is_waiting_for_user():
		if stage.get_selected_follower() == self and stage.get_unit_at(pos) == null:
			if stage.get_terrain_at(pos) in deployable_terrain \
				and can_be_deployed():
					deploy_self(pos)
	elif alive and waiting_for_user:
		confirm_facing()
	elif alive:
		if pos == position:
			for skill in $Skills.get_children():
				if skill.is_available():
					skill.activate()


func _on_Cursor_cancel_issued(pos):
	._on_Cursor_cancel_issued(pos)
	if alive and waiting_for_user:
		stage.undo()


func get_stat_after_statuses(stat_name, base_value):
	var ret = .get_stat_after_statuses(stat_name, base_value)
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
	for unit in group:
		unit.cooldown = get_stat("cooldown")
	.die()
	waiting_for_user = false
	if summoner:
		summoner.recover_faith(ceil(get_stat("cost") / 2))
	for enemy in blocked:
		enemy.blocker = null


var previewing = false

func _on_Cursor_hovered(pos):
	._on_Cursor_hovered(pos)
	$Ranges.visible = $Ranges.visible or waiting_for_user
	if not get_alive_in_group() \
		and stage.get_selected_follower() == self \
		and stage.get_unit_at(pos) == null \
		and stage.get_terrain_at(pos) in deployable_terrain \
		and summoner.faith >= get_stat("cost") \
		and cooldown == 0:
			position = pos
			previewing = true
	else:
		previewing = false


###############################################################################
#        Facing logic                                                         #
###############################################################################


enum Facing {RIGHT = 0, DOWN = 90, LEFT = 180, UP = 270}
export(Facing) var facing = Facing.values()[wind]


var waiting_for_user = false


func face_mouse():
	var relative_pos = get_global_mouse_position() - position - Vector2(stage.get_cell_size(), stage.get_cell_size()) / 2
	var theta = fposmod(rad2deg(atan2(relative_pos.y, relative_pos.x)), 360)
	
	if fmod((theta - 45), 90) != 0:
		facing = int(ceil((theta - 45) / 90) * 90)


func confirm_facing():
	waiting_for_user = false
	if name in stage.summoned_order:
		stage.summoned_order.erase(name)
	stage.summoned_order.push_back(name)
	stage.replace_last_state() # the last state should be right before confirming facing


###############################################################################
#        Blocking logic                                                       #
###############################################################################


export(Array, Vector2) var base_block_range = [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(0, -1)]
export var base_block_count = 2


var blocked = []


func block_enemies():
	var block_range = get_stat("block_range")
	var block_count = get_stat("block_count")
	
	var blockable_enemies_in_range = get_units_in_range_of_type(block_range, UnitType.ENEMY)
	
	for enemy in blockable_enemies_in_range:
		if enemy.blocker != null or enemy.get_stat("unblockable"):
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
	waiting_for_user = false


###############################################################################
#        Voice Lines                                                          #
###############################################################################

export var voice_lines = []

func play_voice_line():
	if voice_lines.empty():
		return
	
	var audio = AudioStreamPlayer2D.new()
	add_child(audio)
	audio.stream = voice_lines[randi() % len(voice_lines)]
	audio.pitch_scale = 1.35
	audio.volume_db = linear2db(Game.settings["voices_volume"])
	audio.play()
