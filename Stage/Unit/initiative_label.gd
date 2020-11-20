extends Label


func _process(_delta) -> void:
	var parent: Unit = get_parent()
	var initiative = parent.initiative
	modulate = (Color.lightgreen if parent.bonus_initiative > 0 else Color.white) if parent.initiative > 0 else Color.deeppink
	text = str(parent.initiative) if parent.initiative > 0 else "í ½í»‡í ½í»‡í ½í»‡-"
