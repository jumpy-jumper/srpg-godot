class_name Gate
extends Unit


export(String, MULTILINE) var spawn_info = ""
var spawn_ticks = []
var enemies = {}

var path = []

func get_type_of_self():
	return UnitType.GATE


func _ready():		
	# Parse the spawn ticks	
	var regex = RegEx.new()
	regex.compile("[0-9]+") # splits by numbers
	for n in regex.search_all(spawn_info):
		n = int(n.get_string())
		assert(not n in spawn_ticks)
		spawn_ticks.append(n)
	
	for enemy in get_children():
		if enemy is Enemy:
			remove_child(enemy)
			enemies[spawn_ticks.pop_front()] = enemy
			enemy.alive = false
			enemy.gate = self
	
	marked = true
	
	$"Path Indicator".modulate = modulate


var prev_pos = Vector2.ZERO

func _process(_delta):
	$"Sprite/UI".visible = alive
	if not $DeathTweener.is_active():
		modulate.a = 1.0 if alive else 0
	elif alive:
		$DeathTweener.stop_all()
		modulate.a = 1.0
	
	if Input.is_action_just_pressed("show_gate_paths"):
		marked = not marked
	if stage.cursor.position == position or marked:
		var path = []
		for i in range(len(self.path)):
			path.append(self.path[i]-global_position)
		$"Path Indicator".points = PoolVector2Array(path)
		$"Path Indicator".visible = true
	else:
		$"Path Indicator".visible = marked
	
	if position != prev_pos:
		initialize_path()
	prev_pos = position
	
	if OS.is_debug_build():
		initialize_path()


func initialize_path():
	if len(enemies.values()) > 0:
		path = stage.get_path_to_target(position, stage.get_selected_summoner().position, \
			enemies.values()[0].traversable)
	else:
		path = []
	

func spawn_enemy():
	$Blocked.visible = false

	if enemies.has(stage.cur_tick):
		var enemy = enemies[stage.cur_tick]
		
		if len(path) > 0 and stage.get_unit_at(path[1]) == null:
			enemy.alive = true
			enemy.position = path[1]
			enemy.base_level = get_stat("level", base_level)
			enemy.heal_to_full()
			var movement_array = enemy.get_stat("movement", enemy.base_movement)
			enemy.movement = movement_array[(stage.cur_tick) % len(movement_array)]
			if enemy in stage.summoned_order:
				stage.summoned_order.erase(enemy)
			stage.summoned_order.push_back(enemy)
		else:
			$Blocked.visible = true
		
		# Die if there are no more enemies to spawn
		for tick in enemies.keys():
			if tick > stage.cur_tick:
				return
		die()


func _on_Cursor_confirm_issued(pos):
	._on_Cursor_confirm_issued(pos)
	if pos == position:
		marked = not marked


onready var base_path_alpha = $"Path Indicator".default_color.a


func _on_Cursor_hovered(pos):
	._on_Cursor_hovered(pos)
	if pos == position:
		$"Path Indicator".default_color.a = (1 - pow(base_path_alpha, 2))
	else:
		$"Path Indicator".default_color.a = base_path_alpha


func on_Terrain_settings_changed():
	initialize_path()



###############################################################################
#        State                                                                #
###############################################################################


func get_state():
	var ret = .get_state()
	ret["blocked"] = get_node("Blocked").visible
	ret["path"] = path + []
	return ret


func load_state(state):
	.load_state(state)
	get_node("Blocked").visible = state["blocked"]
	path = state["path"]
