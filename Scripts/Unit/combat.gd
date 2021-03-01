class_name Combat


enum Type { CLASH, WOUND, CRITICAL, LETHAL }
var type
var attacker
var defender
var attacker_ini
var defender_ini
var wound_cond
var crit_cond
var lethal_cond


func _print():
	print("Type: ", Type.keys()[type])
	print("Final Attacker INI: ", attacker_ini)
	print("Final Defender INI: ", defender_ini)
	print("INI to Wound: ", wound_cond)
	print("INI to Crit: ", crit_cond)
	print("INI to Lethal: ", lethal_cond)
	print()


func _init(a, d):
	self.attacker = a
	self.defender = d

	var atk = 0
	var def = 0
	if attacker.weapon:
		atk = a.weapon.might
		def = d.get_stats()[a.weapon.stat]

	wound_cond = def - atk
	crit_cond = (def * 2) - atk
	lethal_cond = (def * 3) - atk

	if a.get_ini() >= d.get_ini() * 2 and a.get_ini() >= wound_cond:
		if a.get_ini() >= lethal_cond:
			type = Type.LETHAL
		elif a.get_ini() >= crit_cond:
			type = Type.CRITICAL
		else:
			type = Type.WOUND
	else:
		type = Type.CLASH

	attacker_ini = a.get_ini()
	defender_ini = 0

	if type == Type.CLASH:
		defender_ini = d.get_ini()
		var a_atk = max(a.get_stats()[a.weapon.stat], 0)
		var d_atk = max(d.get_stats()[d.weapon.stat], 0)
		if a_atk == 0 and d_atk == 0:
			attacker_ini = 0
			defender_ini = 0
		else:
			var a_turn = true
			while attacker_ini > 0 and defender_ini > 0:
				if a_turn:
					defender_ini -= a_atk
				else:
					attacker_ini -= d_atk
				a_turn = !a_turn

	attacker_ini -= a.get_ini() - a.ini_base
	defender_ini -= d.get_ini() - d.ini_base
