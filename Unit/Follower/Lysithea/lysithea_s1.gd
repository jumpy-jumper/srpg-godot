extends Skill
class_name Lysithea_S1


export var bonus_atk_step = 0.4
export var bonus_atk_max = 6.2
var bonus_atk = 0.0


var bonus_atk_status_cache = null


onready var base_description = description


func _process(_delta):
	description = base_description + " (Current: +" + str(round(bonus_atk*100)) + "%)" if bonus_atk > 0 else base_description


func tick():
	.tick()
	if not is_active() and is_available():
		bonus_atk = min(bonus_atk_max, bonus_atk_step + bonus_atk)
	

func activate():
	.activate()
	var bonus_atk_status = Status.new()
	bonus_atk_status.stat_additive_multipliers["atk"] = bonus_atk
	unit.get_node("Statuses").add_child(bonus_atk_status)
	bonus_atk_status_cache = bonus_atk_status


func deactivate():
	.deactivate()
	bonus_atk = 0.0
	if bonus_atk_status_cache:
		bonus_atk_status_cache.queue_free()
		bonus_atk_status_cache = null
