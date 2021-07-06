class_name Unit
extends Node2D


export var unit_name = ""


enum UnitType {UNDEFINED, SUMMONER, FOLLOWER, GATE, ENEMY}


func get_type_of_self():
	return UnitType.UNDEFINED


###############################################################################
#        Main logic                                                           #
###############################################################################


var stage = null

var alive = true


func _ready():
	yield(get_tree(), "idle_frame")


func _process(_delta):
	visible = alive
	if alive:
		if stage:
			$Selected.visible = stage.selected_unit == self
			if (Input.is_action_just_pressed("debug_activate_skill")):
				if (stage.get_node("Cursor").position == position):
					for skill in $Skills.get_children():
						if skill.activation != skill.Activation.NONE \
							and skill.activation != skill.Activation.EVERY_TICK:
								if skill.is_active():
									skill.deactivate()
								else:
									skill.activate()


func _on_Cursor_confirm_issued(pos):
	if pos == position:
		print(unit_name)
		print("LV: " + str(get_stat("level", base_level)))
		print("HP: " + str(hp) + "/" + str(get_stat("max_hp", base_max_hp)))
		print("ATK: " + str(get_stat("atk", base_atk)))
		print("DEF: " + str(get_stat("def", base_def)))
		print("RES: " + str(get_stat("res", base_res)))
		if $"Skills/Basic Attack":
			print("Target Count: " + str(get_stat("target_count", $"Skills/Basic Attack".base_target_count)))
			print("Attack Count: " + str(get_stat("attack_count", $"Skills/Basic Attack".base_attack_count)))
		print()


func _on_Cursor_cancel_issued(pos):
	pass


func _on_Cursor_hovered(pos):
	$Ranges.visible = position == pos
		
		
func _on_Cursor_moved(pos):
	pass


func tick():
	if alive:
		for skill in $Skills.get_children():
			skill.tick()
	hp = min(hp, get_stat("max_hp", base_max_hp))
		

###############################################################################
#        Stats logic                                                          #
###############################################################################


export var base_level = 1
export var base_max_hp = 2000
export var base_atk = 500
export var base_def = 200
export var base_res = 0

onready var hp = get_stat("max_hp", base_max_hp)


const AFFECTED_BY_LEVEL = ["max_hp", "atk", "def"]


const BONUS_PER_LEVEL = 0.067326582


func get_stat_after_level(stat_name, base_value):
	if stat_name in AFFECTED_BY_LEVEL:
		return floor(base_value * (1 + BONUS_PER_LEVEL * get_stat_after_statuses("level", base_level)))
	else:
		return base_value
	
	
func get_stat_after_statuses(stat_name, base_value):
	var ret = base_value
	
	if stat_name == "movement":
		for status in $Statuses.get_children():
			if status.movement_overwrite:
				return status.movement_overwrite
			elif status.movement_bonus:
				for i in range(len(ret)):
					ret[i] += status.movement_bonus[i]
		return ret
	
	if stat_name == "skill_range":
		for status in $Statuses.get_children():
			if status.skill_range_overwrite:
				return status.skill_range_overwrite
		return ret
	
	if stat_name == "block_range":
		for status in $Statuses.get_children():
			if status.block_range_overwrite:
				return status.block_range_overwrite
		return ret
	
	if stat_name == "faith_recovery":
		return ret
	
	var additive_multiplier = 1.0 
	var multiplicative_multiplier = 1.0

	for status in $Statuses.get_children():
		if status.stat_overwrites.has(stat_name):
			return status.stat_overwrites[stat_name]
		if status.stat_flat_bonuses.has(stat_name):
			ret += status.stat_flat_bonuses[stat_name]
		if status.stat_additive_multipliers.has(stat_name):
			additive_multiplier += status.stat_additive_multipliers[stat_name]
		if status.stat_multiplicative_multipliers.has(stat_name):
			multiplicative_multiplier *= status.stat_multiplicative_multipliers[stat_name]
	
	return floor(ret * additive_multiplier * multiplicative_multiplier)


func get_stat(stat_name, base_value):
	return get_stat_after_statuses(stat_name, get_stat_after_level(stat_name, base_value))


###############################################################################
#        Combat logic                                                         #
###############################################################################


signal acted(unit)
signal dead(unit)


enum DamageType {PHYSICAL, MAGIC, TRUE}


func take_damage(amount = 1, damage_type = DamageType.PHYSICAL):
	amount = floor(amount * get_stat("incoming_damage", 1))
	
	if damage_type == DamageType.PHYSICAL:
		amount -= get_stat("def", base_def)
	elif damage_type == DamageType.MAGIC:
		amount *= (1 - (get_stat("res", base_res) / 100.0))
	
	hp -= max(amount, 0)
	if hp <= 0:
		die()


func heal(amount = 1):
	amount *= get_stat("incoming_healing", 1)
	
	hp += max(amount, 0)
	hp = min(get_stat("max_hp", base_max_hp), hp)


func heal_to_full():
	hp = get_stat("max_hp", base_max_hp)


func die():
	emit_signal("dead", self)
	alive = false
	heal_to_full()



###############################################################################
#        Range logic                                                          #
###############################################################################


func get_units_in_range_of_type(_range, unit_type):
	var ret = []
	for pos in _range:
		var u = stage.get_unit_at(position + pos * stage.get_cell_size())
		if u and u.get_type_of_self() == unit_type:
			ret.append(u)
	return ret
