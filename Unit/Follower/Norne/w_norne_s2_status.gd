extends Status


func _process(_delta):
	stat_flat_bonuses["attack_count"] = issuer_unit.get_node("Skills/" + issuer_name).ticks_left
