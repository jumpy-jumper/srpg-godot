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
		if $Range.visible and stage:
			update_range()


func update_range():
	var skill_active = false
	for skill in $Skills.get_children():
		if skill.active:
			skill_active = true
			break
	$Range.update_range($Skills.get_children()[0].get_skill_range(), stage.get_cell_size(), skill_active)


func _on_Cursor_confirm_issued(pos):
	pass


func _on_Cursor_cancel_issued(pos):
	pass


func _on_Cursor_hovered(pos):
	$Range.visible = position == pos
		
		
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
	hp -= max(amount, 0)
	if hp <= 0:
		die()


func die():
	emit_signal("dead", self)
	alive = false
