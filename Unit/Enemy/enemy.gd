class_name Enemy
extends Unit


var gate = null


func get_type_of_self():
	return UnitType.ENEMY


func get_type_of_enemy():
	return UnitType.FOLLOWER


func _ready():
	var movement_array = get_stat("movement", base_movement)
	movement = movement_array[0]


func _process(_delta):
	visible = alive
	if stage.cursor.position == position or marked:
		var path = ([] + gate.path) if gate else (stage.get_path_to_target(position, stage.get_selected_summoner().position, traversable))
		for i in range(len(path)):
			path[i] += Vector2(stage.get_cell_size() / 2, stage.get_cell_size() / 2)
			path[i] -= global_position
		$"Path Indicator".points = PoolVector2Array(path)
		$"Path Indicator".visible = true
	else:
		$"Path Indicator".visible = marked


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


###############################################################################
#        Movement	                                                          #
###############################################################################


export var base_movement = [0, 1, 0, 1]
export(Array, Resource) var traversable = []


var movement = 0
const MOV_INTERP_DURATION = 0.125


func move():
	if blocker != null:
		$Blocked.visible = true
		return
		
	$Blocked.visible = false
	
	var target = stage.get_selected_summoner()		
	var path = ([] + gate.path) if gate else (stage.get_path_to_target(position, stage.get_selected_summoner().position, traversable))
	
	while (path[0] != position):
		path.pop_front()
	
	var leftover_movement = movement
	
	var newpos = position
	
	for i in range(movement + 1):
		if i < len(path):
			var unit = stage.get_unit_at(path[i])
			if unit:
				if unit.get_type_of_self() == UnitType.SUMMONER:
					unit.apply_damage()
					die()
					break
				elif unit.get_type_of_self() == UnitType.FOLLOWER:
					continue
				elif unit.get_type_of_self() == UnitType.ENEMY:
					continue
			newpos = path[i]
			leftover_movement = movement - i

	var movement_array = get_stat("movement", base_movement)
	movement = leftover_movement + movement_array[(stage.cur_tick) % len(movement_array)]
	
	var oldpos = position
	position = newpos
	
	$MovementTweener.interpolate_property($Sprite, "global_position",
	oldpos, newpos, MOV_INTERP_DURATION,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$MovementTweener.start()


###############################################################################
#        Block logic                                                          #
###############################################################################

var blocker = null
