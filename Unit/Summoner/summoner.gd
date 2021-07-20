class_name Summoner
extends Unit


enum Wind {EAST, SOUTH, WEST, NORTH}
export var wind = Wind.EAST


var followers = []
var summoned_order = []


func get_type_of_self():
	return UnitType.SUMMONER

func get_level_advancing_skill():
	return $"Skills/Awaken"

func _ready():
	for unit in get_children():
		if unit is Follower:
			remove_child(unit)
			followers.append(unit)
			unit.alive = false
			unit.summoner = self


func _process(_delta):
	var skills = $Skills.get_children()
	for skill in skills:
		skill.sp = faith
		if skill.is_available():
			skill.activate()



func _on_Cursor_confirm_issued(pos):
	._on_Cursor_confirm_issued(pos)
	if alive:
		if pos == position:
			for skill in $Skills.get_children():
				if skill.is_available():
					skill.activate()

###############################################################################
#        Stats logic                                                          #
###############################################################################


export var base_max_faith = 99

export var faith = 20


###############################################################################
#        Combat logic                                                         #
###############################################################################


func apply_damage(amount = 1, damage_type = DamageType.PHYSICAL):
	hp -= 1
	if hp <= 0:
		die()


func recover_faith(amount = 1):
	faith = min(faith + amount, get_stat("max_faith", base_max_faith))


###############################################################################
#        State                                                                #
###############################################################################


func get_state():
	var ret = .get_state()
	ret["faith"] = faith
	return ret


func load_state(state):
	.load_state(state)
	faith = state["faith"]
