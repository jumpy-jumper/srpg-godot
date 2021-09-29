class_name Gate
extends Unit


export var spawn_round = 1
export var lifespan = 1
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
	if not $DeathTweener.is_active():
		$Sprite.modulate.a = 1.0 if alive else 0
	elif alive:
		$DeathTweener.stop_all()
		$Sprite.modulate.a = 1.0
	
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
	
	if $"Path Indicator".visible and not alive:
		$"Path Indicator".visible = false
		for enemy in enemies.values():
			if enemy.alive:
				$"Path Indicator".visible = true
	
	if position != prev_pos:
		initialize_path()
	prev_pos = position
	
	if OS.is_debug_build():
		#initialize_path()
		pass


func die():
	emit_signal("dead", self)
	alive = false
	heal_to_full()
	for skill in $Skills.get_children():
		skill.initialize()
	shield = 0
	
	$DeathTweener.interpolate_property($Sprite, "modulate:a",
	0.75, 0, DEATH_TWEEN_DURATION,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$DeathTweener.start()


func initialize_path():
	if len(enemies.values()) > 0:
		path = stage.get_path_to_target(position, stage.summoners_cache[wind].position, \
			enemies.values()[0].traversable)
	else:
		path = []
	

func spawn_enemy():
	$Sprite/Blocked.visible = false

	if enemies.has(stage.cur_tick):
		var enemy = enemies[stage.cur_tick]
		
		if len(path) > 0 and stage.get_unit_at(path[1]) == null:
			enemy.alive = true
			enemy.position = path[1]
			enemy.emit_signal("moved", enemy, enemy.position)
			enemy.base_level = get_stat("level")
			enemy.heal_to_full()
			var movement_array = enemy.get_stat("movement")
			enemy.movement = movement_array[(stage.cur_tick) % len(movement_array)]
			if enemy.name in stage.summoned_order:
				stage.summoned_order.erase(enemy.name)
			stage.summoned_order.push_back(enemy.name)
		else:
			$Sprite/Blocked.visible = true
		
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
	ret["blocked"] = get_node("Sprite/Blocked").visible
	ret["path"] = path + []
	return ret


func load_state(state):
	.load_state(state)
	get_node("Sprite/Blocked").visible = state["blocked"]
	path = state["path"]
