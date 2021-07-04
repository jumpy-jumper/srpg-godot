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
	if stage:
		update_range()


func _process(_delta):
		
	if alive:
		if stage:
			$Selected.visible = stage.selected_unit == self
			if (Input.is_action_just_pressed("debug_activate_skill")):
				if (stage.get_node("Cursor").position == position):
					for skill in $Skills.get_children():
						if skill.activation != skill.Activation.NONE \
							and skill.activation != skill.Activation.TICK:
								if skill.active:
									skill.deactivate()
								else:
									skill.activate()
		if $Ranges.visible and stage:
			update_range()


func update_range():
	if len($Skills.get_children()) > 0:
		var skill_active = false
		for skill in $Skills.get_children():
			if skill.active:
				skill_active = true
				break
		$"Ranges/Skill Range".update_range($Skills.get_children()[0].get_skill_range(), stage.get_cell_size(), skill_active)


func _on_Cursor_confirm_issued(pos):
	pass


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
		

###############################################################################
#        Stats logic                                                          #
###############################################################################


export var base_level = 1
export var base_max_hp = 2000
export var base_atk = 500
export var base_def = 200
export var base_res = 0

export (int) var hp = base_max_hp


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
	
	return ret * additive_multiplier * multiplicative_multiplier


###############################################################################
#        Combat logic                                                         #
###############################################################################


signal dead(unit)


enum DamageType {PHYSICAL, MAGIC, TRUE}


func take_damage(amount = 1, damage_type = DamageType.PHYSICAL):
	amount *= get_stat_after_statuses("incoming_damage", 1)
	
	if damage_type == DamageType.PHYSICAL:
		amount -= get_stat_after_statuses("def", base_def)
	elif damage_type == DamageType.MAGIC:
		amount *= (1 - (get_stat_after_statuses("res", base_res) / 100.0))
	
	hp -= max(amount, 0)
	if hp <= 0:
		die()


func die():
	emit_signal("dead", self)
	alive = false



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
