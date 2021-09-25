extends Skill

var atk_buff = preload("res://Unit/Follower/Dieck/s_dieck_s1_atk+.tscn")
var def_buff = preload("res://Unit/Follower/Dieck/s_dieck_s1_def+.tscn")

func tick():
	.tick()
	if is_active():
		if unit.stage.get_randb():
			unit.get_node("Statuses").add_child(atk_buff.instance())
		else:
			unit.get_node("Statuses").add_child(def_buff.instance())
