class_name Summoner
extends Unit


enum Wind {EAST, SOUTH, WEST, NORTH}
export var wind = Wind.EAST


var followers = []
var summoned_order = []


func get_type_of_self():
	return UnitType.SUMMONER


func _ready():
	for unit in get_children():
		if unit is Follower:
			remove_child(unit)
			followers.append(unit)
			unit.alive = false
			unit.summoner = self

func _process(_delta):
	visible = alive


###############################################################################
#        Stats logic                                                          #
###############################################################################


export var base_max_faith = 99

export var faith = 20


###############################################################################
#        Combat logic                                                         #
###############################################################################


func take_damage(amount = 1, damage_type = DamageType.PHYSICAL):
	hp -= 1
	if hp <= 0:
		die()


func recover_faith(amount = 1):
	faith = min(faith + amount, get_stat("max_faith", base_max_faith))
