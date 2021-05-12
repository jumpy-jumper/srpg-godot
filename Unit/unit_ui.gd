extends Control


func _process(delta):
	var unit = $".."
	$"SP".text = str(unit.sp) if unit.sp > 0 else "í ½í»‡í ½í»‡í ½í»‡-"
	$Health.text = str(unit.hp)
