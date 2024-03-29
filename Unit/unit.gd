class_name Unit
extends Node2D


export var unit_name = ""


enum UnitType {UNDEFINED, SUMMONER, FOLLOWER, GATE, ENEMY}


enum Wind {EAST, SOUTH, WEST, NORTH}
export(Wind) var wind = Wind.EAST


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
	
	$Sprite/Invisible.visible = get_stat("invisible")
	
	if alive:
		hp = min(hp, get_stat("max_hp"))
		
		if (Input.is_action_just_pressed("debug_activate_skill")):
			if (stage.cursor.position == position):
				for skill in $Skills.get_children():
					if skill.activation != skill.Activation.PASSIVE \
						and skill.activation != skill.Activation.EVERY_TICK:
							if skill.is_active():
								skill.deactivate()
							else:
								skill.activate()
		
		if (Input.is_action_just_pressed("debug_kill")):
			if (stage.cursor.position == position):
				die()
				stage.append_state()
		
		if (Input.is_action_just_pressed("mark")):
			if (stage.cursor.position == position):
				marked = not marked
	
		display_toasts()
	else:
		hp = get_stat("max_hp")
		

func _on_Cursor_confirm_issued(pos):
	pass


func _on_Cursor_cancel_issued(pos):
	pass


func _on_Cursor_hovered(pos):
	$Ranges.visible = position == pos or marked


func _on_Cursor_moved(pos):
	pass


func tick_skills():
	var skills = [] + $Skills.get_children()
	skills.invert()
	for skill in skills:
		skill.tick()


func tick_statuses():
	var statuses = [] + $Statuses.get_children()
	for status in statuses:
		status.tick()


func _on_Stage_tick_started():
	if alive:
		for skill in $Skills.get_children():
			if not skill.is_active():
				if skill.activation == skill.Activation.TURN_START:
					skill.activate()


func _on_Stage_tick_ended():
	if alive:
		for skill in $Skills.get_children():
			if not skill.is_active() and not skill.activation == skill.Activation.PASSIVE:
				skill.remove_statuses()
				var sp_cost = skill.get_stat("skill_cost")
				if skill.activation == skill.Activation.SP_AUTO and skill.sp == sp_cost:
					skill.activate()


###############################################################################
#        Stats logic                                                          #
###############################################################################


export var base_level = 1
export var base_max_hp = 2000
export var base_atk = 500
export var base_def = 200
export var base_res = 0

onready var hp = get_stat("max_hp")
var shield = 0


const AFFECTED_BY_LEVEL = ["max_hp", "atk", "def"]
const BOOL_STATS = ["invisible", "unblockable", "invincible"]
const NUMERICAL_STATS = ["level", "max_hp", "max_faith", "atk", "def", "res", \
	"cost", "skill_cost", "skill_initial_sp", "attack_count", "target_count", \
	"block_count", "damage_type", "incoming_damage", "incoming_healing", "incoming_recovery", \
	"skill_duration", "cooldown", "incoming_shield", "targeting_priority", "charges"]
const INTEGER_STATS = ["level", "max_hp", "max_faith", "atk", "def", "res", \
	"cost", "skill_cost", "skill_initial_sp", "attack_count", "target_count", \
	"block_count", "skill_duration", "cooldown"]
const ARRAY_STATS = ["movement", "skill_range", "block_range", "faith_recovery"]

var BASE_VALUES = {
	"max_hp" : "base_max_hp",
	"atk" : "base_atk",
	"def" : "base_def",
	"res" : "base_res",
	"invisible" : false,
	"unblockable" : false,
	"invincible" : false,
	"level" : "base_level",
	"max_faith" : "base_max_faith",
	"cost" : "base_cost",
	"block_count" : "base_block_count",
	"cooldown" : "base_cooldown",
	"movement" : "base_movement",
	"faith_recovery" : "base_faith_recovery",
	"block_range" : "base_block_range",
	"incoming_damage" : 1,
	"incoming_healing" : 1,
	"incoming_recovery" : 1,
	"incoming_shield" : 1,
}

func get_stat(stat_name):
	var base_value = get(BASE_VALUES[stat_name]) if BASE_VALUES[stat_name] is String else BASE_VALUES[stat_name]
	assert(base_value != null)
	return get_stat_after_statuses(stat_name, get_stat_after_level(stat_name, base_value))

const SCALING_FACTOR = 0.047326582
func get_stat_after_level(stat_name, base_value):
	if stat_name in AFFECTED_BY_LEVEL:
		return floor(base_value * pow(1 + SCALING_FACTOR, get_stat_after_statuses("level", base_level)))
	else:
		return base_value
	
func get_stat_after_statuses(stat_name, base_value):
	assert(stat_name in BOOL_STATS + NUMERICAL_STATS + ARRAY_STATS)
	
	var ret = base_value if stat_name in BOOL_STATS + NUMERICAL_STATS else [] + base_value
	
	for status in $Statuses.get_children():
		if status.stat_overwrites.has(stat_name):
			return status.stat_overwrites[stat_name]
	
	if stat_name in BOOL_STATS:
		return ret
	
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


func get_basic_attack():
	return $"Skills/Basic Attack"


func get_first_activatable_skill():
	for skill in $Skills.get_children():
		if skill.activation == skill.Activation.SP_MANUAL \
			or skill.activation == skill.Activation.SP_AUTO \
			or skill.activation == skill.Activation.DEPLOYMENT:
				return skill
	return null


func get_attack_range():
	var basic_attack = get_basic_attack()
	if basic_attack:
		return basic_attack.get_stat("skill_range")
	return []


func is_full_hp():
	return hp >= get_stat("max_hp")


###############################################################################
#        Combat logic                                                         #
###############################################################################


signal dead(unit)
signal moved(unit, from)


enum DamageType {PHYSICAL, MAGIC, TRUE, HEALING, SHIELD, SHIELD_DAMAGE, RECOVERY}


var physical_color = Color.lightcoral
var magic_color = Color.blue
var true_color = Color.white
var shield_damage_color = Color.goldenrod
var healing_color = Color.green
var recovery_color = Color.lightgreen
var shield_color = Color.goldenrod
var colors = [physical_color, magic_color, true_color, healing_color, shield_color, shield_damage_color, recovery_color]

var targeting_toast = preload("res://Unit/targeting_toast.tscn")
var damage_toast = preload("res://Unit/damage_toast.tscn")

var damage_toasts = []
var targeting_toasts = []


func deal_damage_to_target(target, amount, damage_type):
	target.apply_damage(amount, damage_type)

	var toast = targeting_toast.instance()
	toast.attacker = self
	toast.attackee = target
	toast.gradient = toast.gradient.duplicate()
	toast.gradient.set_color(1, colors[damage_type])
	targeting_toasts.append(toast)


func apply_damage(amount, damage_type, no_toast = false):
	if damage_type == DamageType.HEALING or damage_type == DamageType.RECOVERY:
		amount *= get_stat("incoming_recovery")
		if damage_type == DamageType.HEALING:
			amount *= get_stat("incoming_healing")
		hp = min(hp + max(amount, 0), get_stat("max_hp"))
		if not no_toast:
			damage_toasts.append(get_damage_toast(amount, colors[DamageType.HEALING]))
		return
	
	if damage_type == DamageType.SHIELD:
		amount *= get_stat("incoming_shield")
		shield += max(amount, 0)
		if not no_toast:
			damage_toasts.append(get_damage_toast(amount, colors[DamageType.SHIELD]))
		return
		
	if damage_type == DamageType.PHYSICAL:
		amount -= get_stat("def")
	elif damage_type == DamageType.MAGIC:
		amount = floor(amount * (1 - (get_stat("res") / 100.0)))
	elif damage_type == DamageType.SHIELD_DAMAGE:
		amount = min(shield, amount)

	amount = floor(amount * get_stat("incoming_damage"))
	
	var shield_damage = min(shield, amount)
	if shield_damage > 0:
		amount -= shield_damage
		shield -= shield_damage
		if not no_toast:
			damage_toasts.append(get_damage_toast(-shield_damage, colors[DamageType.SHIELD_DAMAGE]))
	
	if amount > 0:
		hp -= amount
		if hp <= 0:
			die()
		hp = min(get_stat("max_hp"), hp)
	
	if damage_type != DamageType.SHIELD_DAMAGE and (amount > 0 or shield == 0):
		if not no_toast:
			damage_toasts.append(get_damage_toast(max(amount, 0), colors[damage_type]))
	
	if damage_type == DamageType.PHYSICAL \
		or damage_type == DamageType.PHYSICAL \
		or damage_type == DamageType.PHYSICAL :
			for skill in $Skills.get_children():
				if skill.recovery == skill.Recovery.DEFENSIVE:
					skill.sp += 1


func get_damage_toast(amount, color):
	var toast = damage_toast.instance()
	toast.amount = amount
	toast.color = color
	return toast

func heal_to_full():
	apply_damage(get_stat("max_hp"), DamageType.HEALING, true)


func display_toasts():
	for i in range(len(damage_toasts)):
		damage_toasts[i].position += position
		damage_toasts[i].position.y += i * damage_toasts[i].y_step
		stage.add_child(damage_toasts[i])
	for toast in targeting_toasts:
		toast.position += position
		stage.add_child(toast)
	damage_toasts.clear()
	targeting_toasts.clear()
	

const DEATH_TWEEN_DURATION = 0.5


func die():
	emit_signal("dead", self)
	alive = false
	heal_to_full()
	shield = 0
	
	for status in $Statuses.get_children():
		if not status.persists_through_death:
			status.free()
	for skill in $Skills.get_children():
		skill.initialize()
	
	$DeathTweener.interpolate_property(self, "modulate:a",
	0.75, 0, DEATH_TWEEN_DURATION,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$DeathTweener.start()


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
	ret.sort_custom(get_basic_attack(), "closest_to_summoner_comparison")
	return ret



###############################################################################
#        State                                                                #
###############################################################################


func get_state():
	var ret = {}		
	ret["position"] = position
	ret["alive"] = alive
	ret["hp"] = hp
	ret["shield"] = shield
	
	for child in $Skills.get_children() + $Statuses.get_children():
		var child_state = child.get_state()
		for key in child_state.keys():
			ret[child.name + "\t" + key] = child_state[key]
	
	return ret


func load_state(state):
	position = state["position"]
	alive = state["alive"]
	hp = state["hp"]
	shield = state["shield"]
	
	for child in $Skills.get_children() + $Statuses.get_children():
		child.free()
	
	var child_states = {}
	for key in state.keys():
		if "\t" in key:
			var split = key.split("\t")
			if not child_states.has(split[0]):
				child_states[split[0]] = {}
			child_states[split[0]][split[1]] = state[key]
	
	for child in child_states.keys():
		var new_child = Node.new()
		new_child.script = load(child_states[child]["script"])
		if new_child is Skill:
			$Skills.add_child(new_child)
		elif new_child is Status:
			$Statuses.add_child(new_child)
		new_child.load_state(child_states[child])
