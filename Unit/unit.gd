class_name Unit
extends Node2D


export var unit_name = ""


enum UnitType {UNDEFINED, SUMMONER, FOLLOWER, GATE, ENEMY}


func get_type_of_self():
	return UnitType.UNDEFINED

func get_position():
	return position

###############################################################################
#        Main logic                                                           #
###############################################################################


var stage = null
var alive = true


func _ready():
	if unit_name == "":
		unit_name = ("Gate of " if get_type_of_self() == UnitType.GATE else "") + name
	for skill in $Skills.get_children():
		skill.initialize()


func _process(_delta):
	if alive:
		hp = min(hp, get_stat("max_hp", base_max_hp))
		
		if (Input.is_action_just_pressed("debug_activate_skill")):
			if (stage.cursor.position == position):
				for skill in $Skills.get_children():
					if skill.activation != skill.Activation.NONE \
						and skill.activation != skill.Activation.EVERY_TICK:
							if skill.is_active():
								skill.deactivate()
							else:
								skill.activate()
		
		if (Input.is_action_just_pressed("debug_kill")):
			if (stage.cursor.position == position):
				die()
		
		if (Input.is_action_just_pressed("mark")):
			if (stage.cursor.position == position):
				marked = not marked
	else:
		hp = get_stat("max_hp", base_max_hp)
		

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
var shield = 0


const AFFECTED_BY_LEVEL = ["max_hp", "atk", "def"]
const NUMERICAL_STATS = ["level", "max_hp", "max_faith", "atk", "def", "res", \
	"cost", "skill_cost", "skill_initial_sp", "attack_count", "target_count", \
	"block_count", "damage_type", "incoming_damage", "incoming_healing", \
	"skill_duration", "cooldown", "incoming_shield"]
const INTEGER_STATS = ["level", "max_hp", "max_faith", "atk", "def", "res", \
	"cost", "skill_cost", "skill_initial_sp", "attack_count", "target_count", \
	"block_count", "skill_duration", "cooldown"]
const ARRAY_STATS = ["movement", "skill_range", "block_range", "faith_recovery"]


const SCALING_FACTOR = 0.047326582

func get_stat_after_level(stat_name, base_value):
	if stat_name in AFFECTED_BY_LEVEL:
		return floor(base_value * pow(1 + SCALING_FACTOR, get_stat_after_statuses("level", base_level)))
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


enum DamageType {PHYSICAL, MAGIC, TRUE, HEALING, SHIELD, SHIELD_DAMAGE}


var physical_color = Color.lightcoral
var magic_color = Color.blue
var true_color = Color.white
var shield_damage_color = Color.goldenrod
var healing_color = Color.green
var shield_color = Color.goldenrod
var colors = [physical_color, magic_color, true_color, healing_color, shield_color, shield_damage_color]

var damage_toast = preload("res://Unit/damage_toast.tscn")

var toasts_this_tick = 0


func apply_damage(amount = 1, damage_type = DamageType.PHYSICAL):
	if damage_type == DamageType.PHYSICAL:
		amount -= get_stat("def", base_def)
	elif damage_type == DamageType.MAGIC:
		amount = floor(amount * (1 - (get_stat("res", base_res) / 100.0)))
	elif damage_type == DamageType.SHIELD_DAMAGE:
		amount = min(shield, amount)

	amount = floor(amount * get_stat("incoming_damage", 1))
	
	var shield_damage = min(shield, amount)
	if shield_damage > 0:
		amount -= shield_damage
		shield -= shield_damage
		display_damage_toast(-shield_damage, colors[DamageType.SHIELD_DAMAGE])
	
	if amount > 0:
		hp -= amount
		if hp <= 0:
			die()
		hp = min(get_stat("max_hp", base_max_hp), hp)
	
	if damage_type != DamageType.SHIELD_DAMAGE and (amount > 0 or shield == 0):
		display_damage_toast(max(amount, 0), colors[damage_type])


func apply_healing(amount = 1):
	amount *= get_stat("incoming_healing", 1)
	hp += max(amount, 0)
	display_damage_toast(amount, colors[DamageType.HEALING])


func heal_to_full():
	var max_hp = get_stat("max_hp", base_max_hp)
	if max_hp - hp > 0:
		hp = max_hp


func apply_shield(amount):
	amount *= get_stat("incoming_shield", 1)
	shield += max(amount, 0)
	display_damage_toast(amount, colors[DamageType.SHIELD])


func display_damage_toast(amount, color):
	var toast = damage_toast.instance()
	toast.amount = amount
	toast.color = color
	toast.position += position
	toast.position.y += toasts_this_tick * toast.y_step
	stage.add_child(toast)
	toasts_this_tick += 1


const DEATH_TWEEN_DURATION = 2

func die():
	emit_signal("dead", self)
	alive = false
	marked = false
	heal_to_full()
	for skill in $Skills.get_children():
		skill.initialize()
	shield = 0




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
