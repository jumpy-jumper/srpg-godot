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
		hp = min(hp, get_stat("max_hp", base_max_hp))
		
		if (Input.is_action_just_pressed("debug_activate_skill")):
			if (stage.get_node("Cursor").position == position):
				for skill in $Skills.get_children():
					if skill.activation != skill.Activation.NONE \
						and skill.activation != skill.Activation.EVERY_TICK:
							if skill.is_active():
								skill.deactivate()
							else:
								skill.activate()


		if (Input.is_action_just_pressed("debug_kill")):
			if (stage.get_node("Cursor").position == position):
				die()


		if (Input.is_action_just_pressed("mark")):
			if (stage.get_node("Cursor").position == position):
				marked = not marked


func _on_Cursor_confirm_issued(pos):
	pass


func _on_Cursor_cancel_issued(pos):
	pass


func _on_Cursor_hovered(pos):
	$Ranges.visible = position == pos or marked


func _on_Cursor_moved(pos):
	pass


func tick_skills():
	if alive:
		var skills = [] + $Skills.get_children()
		skills.invert()
		for skill in skills:
			skill.tick()


func _on_Stage_tick_ended():
	toasts_this_tick = 0


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
const NUMERICAL_STATS = ["level", "max_hp", "max_faith", "atk", "def", "res", \
	"cost", "skill_cost", "skill_initial_sp", "attack_count", "target_count", \
	"block_count", "damage_type", "incoming_damage", "incoming_healing", \
	"skill_duration", "cooldown"]
const INTEGER_STATS = ["level", "max_hp", "max_faith", "atk", "def", "res", \
	"cost", "skill_cost", "skill_initial_sp", "attack_count", "target_count", \
	"block_count", "skill_duration", "cooldown"]
const ARRAY_STATS = ["movement", "skill_range", "block_range", "faith_recovery"]


const BONUS_PER_LEVEL = 0.067326582


func get_stat_after_level(stat_name, base_value):
	if stat_name in AFFECTED_BY_LEVEL:
		return floor(base_value * (1 + BONUS_PER_LEVEL * get_stat_after_statuses("level", base_level)))
	else:
		return base_value
	
	
func get_stat_after_statuses(stat_name, base_value):
	assert(stat_name in NUMERICAL_STATS + ARRAY_STATS)
	
	var ret = base_value if stat_name in NUMERICAL_STATS else [] + base_value
	
	for status in $Statuses.get_children():
		if status.stat_overwrites.has(stat_name):
			return status.stat_overwrites[stat_name]
	
	var additive_multiplier = 1.0 
	var multiplicative_multiplier = 1.0

	if stat_name in NUMERICAL_STATS:
		for status in $Statuses.get_children():
				if status.stat_flat_bonuses.has(stat_name):
					ret += status.stat_flat_bonuses[stat_name]
				if status.stat_additive_multipliers.has(stat_name):
					additive_multiplier += status.stat_additive_multipliers[stat_name]
				if status.stat_multiplicative_multipliers.has(stat_name):
					multiplicative_multiplier *= status.stat_multiplicative_multipliers[stat_name]
		if stat_name in INTEGER_STATS:
			return floor(ret * additive_multiplier * multiplicative_multiplier)
		else:
			return ret * additive_multiplier * multiplicative_multiplier

	elif stat_name in ARRAY_STATS:
		for status in $Statuses.get_children():
			if status.stat_flat_bonuses.has(stat_name):
				for i in range(len(ret)):
					ret[i] += status.stat_flat_bonuses[stat_name][i]
		return ret
	


func get_stat(stat_name, base_value):
	return get_stat_after_statuses(stat_name, get_stat_after_level(stat_name, base_value))


###############################################################################
#        Combat logic                                                         #
###############################################################################


signal dead(unit)


enum DamageType {PHYSICAL, MAGIC, TRUE, HEALING}


var physical_color = Color.lightcoral
var magic_color = Color.blue
var true_color = Color.white
var healing_color = Color.green
var colors = [physical_color, magic_color, true_color, healing_color]


var damage_toast = preload("res://Unit/damage_toast.tscn")

var toasts_this_tick = 0

func take_damage(amount = 1, damage_type = DamageType.PHYSICAL):
	if damage_type == DamageType.PHYSICAL:
		amount -= get_stat("def", base_def)
	elif damage_type == DamageType.MAGIC:
		amount = floor(amount * (1 - (get_stat("res", base_res) / 100.0)))
	
	amount = floor(amount * get_stat("incoming_damage", 1))
	
	amount = max(amount, 0)
	hp -= amount
	if hp <= 0:
		die()
	
	var toast = damage_toast.instance()
	toast.amount = amount
	toast.color = colors[damage_type]
	toast.position += position
	toast.position.y += toasts_this_tick * toast.y_step
	stage.add_child(toast)
	toasts_this_tick += 1


func heal(amount = 1):
	amount *= get_stat("incoming_healing", 1)
	
	hp += max(amount, 0)
	hp = min(get_stat("max_hp", base_max_hp), hp)
	
	var toast = damage_toast.instance()
	toast.amount = amount
	toast.color = colors[DamageType.HEALING]
	toast.position += position
	toast.position.y += toasts_this_tick * toast.y_step
	stage.add_child(toast)
	toasts_this_tick += 1


func heal_to_full():
	hp = get_stat("max_hp", base_max_hp)


func die():
	emit_signal("dead", self)
	alive = false
	heal_to_full()
	for skill in $Skills.get_children():
		skill.initialize()



###############################################################################
#        Range logic                                                          #
###############################################################################


var marked = false


func get_units_in_range_of_type(_range, unit_type):
	var ret = []
	for pos in _range:
		var u = stage.get_unit_at(position + pos * stage.get_cell_size())
		if u and u.get_type_of_self() == unit_type:
			ret.append(u)
	return ret
