extends Label


func _process(_delta) -> void:
	var initiative = get_parent().initiative
	modulate = Color.white if initiative > 0 else Color.deeppink
	text = str(initiative) if initiative > 0 else "í ½í»‡í ½í»‡í ½í»‡-"
