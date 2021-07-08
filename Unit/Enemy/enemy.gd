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
	$Blocked.visible = blocker != null


func _on_Cursor_confirm_issued(pos):
	._on_Cursor_confirm_issued(pos)
	if pos == position:
		marked = not marked


###############################################################################
#        Movement	                                                          #
###############################################################################


export var base_movement = [0, 1, 0, 1]
export(Array, Resource) var traversable = []


var movement = 0
const MOV_INTERP_DURATION = 0.125


func move():
	if blocker != null:
		return
		
	var target = stage.summoners_cache[0]
	var path = stage.get_path_to_target(position, target.position, traversable)
	
	var leftover_movement = movement
	
	var newpos = position
	
	for i in range(movement + 1):
		if i < len(path):
			var unit = stage.get_unit_at(path[i])
			if unit:
				if unit.get_type_of_self() == UnitType.SUMMONER:
					unit.take_damage()
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
	
	$MovementTweener.interpolate_property($Sprite, "global_position",
	position, newpos, MOV_INTERP_DURATION,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$MovementTweener.start()
	
	position = newpos


###############################################################################
#        Block logic                                                          #
###############################################################################

var blocker = null
