class_name Summoner
extends Unit


var followers = []


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
	if not $DeathTweener.is_active():
		modulate.a = 1.0 if alive else 0
	elif alive:
		$DeathTweener.stop_all()
		modulate.a = 1.0
	var skills = $Skills.get_children()
	for skill in skills:
		skill.sp = faith
		if skill.is_available():
			skill.activate()

func _on_Stage_tick_started():
	recover_faith(1)

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


func apply_damage(amount, damage_type, no_toasts = false):
	hp -= 1
	if hp <= 0:
		die()


func recover_faith(amount = 1):
	faith = min(faith + amount, get_stat("max_faith"))


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
