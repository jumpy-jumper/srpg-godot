class_name Summoner
extends Unit


export(Array, Resource) var followers = []


func get_type_of_self():
	return UnitType.SUMMONER


###############################################################################
#        Stats logic                                                          #
###############################################################################


export var base_max_faith = 99
export (int) var faith = 20


###############################################################################
#        Combat logic                                                         #
###############################################################################


func take_damage(amount = 1, damage_type = DamageType.PHYSICAL):
	hp -= 1
	if hp <= 0:
		die()


func die():
	emit_signal("dead", self)